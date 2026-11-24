package com.example.tablet_vscode

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.net.InetSocketAddress
import java.net.Socket

class MainActivity : FlutterActivity() {
    private val channel = "com.example.tablet_vscode/server"
    @Volatile private var isServerStarted = false

    companion object {
        init {
            System.loadLibrary("node")
            System.loadLibrary("native-lib")
        }
    }

    private external fun startNodeWithArguments(arguments: Array<String>): Int

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVSCodeServer" -> if (!isServerStarted) startVSCodeBackground(result)
                else result.success("http://127.0.0.1:8080")
                else -> result.notImplemented()
            }
        }
    }

    private fun startVSCodeBackground(result: MethodChannel.Result) {
        Thread {
            try {
                val targetDir = File(filesDir, "vscode")
                val marker = File(targetDir, ".extracted_v1")
                if (!marker.exists()) {
                    if (targetDir.exists()) targetDir.deleteRecursively()
                    copyAssetFolder("flutter_assets/assets/vscode", targetDir)
                    marker.createNewFile()
                }
                val entry = File(targetDir, "out/server-main.js")
                require(entry.isFile) { "Missing ${entry.path}; add openvscode-server assets." }
                val workspace = File(filesDir, "workspace")
                if (!workspace.exists()) workspace.mkdirs()
                isServerStarted = true
                Thread {
                    startNodeWithArguments(arrayOf(
                        "node", entry.absolutePath, "--host", "127.0.0.1",
                        "--port", "8080", "--without-connection-token",
                        "--default-folder", workspace.absolutePath
                    ))
                    isServerStarted = false
                }.start()
                if (!waitForServerReady("127.0.0.1", 8080)) error("Server did not open port 8080")
                runOnUiThread { result.success("http://127.0.0.1:8080") }
            } catch (error: Exception) {
                isServerStarted = false
                runOnUiThread { result.error("SERVER_ERROR", error.message, null) }
            }
        }.start()
    }

    private fun copyAssetFolder(assetPath: String, destination: File) {
        if (!destination.exists()) destination.mkdirs()
        for (name in assets.list(assetPath).orEmpty()) {
            val source = "$assetPath/$name"
            val target = File(destination, name)
            val children = assets.list(source).orEmpty()
            if (children.isNotEmpty()) copyAssetFolder(source, target)
            else assets.open(source).use { input -> FileOutputStream(target).use { input.copyTo(it) } }
        }
    }

    private fun waitForServerReady(host: String, port: Int): Boolean {
        repeat(60) {
            try { Socket().use { it.connect(InetSocketAddress(host, port), 500); return true } }
            catch (_: Exception) { Thread.sleep(500) }
        }
        return false
    }
}
