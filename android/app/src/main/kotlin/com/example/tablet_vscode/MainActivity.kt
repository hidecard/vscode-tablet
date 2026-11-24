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
                val entry = File(targetDir, "out/server-main.js")
                // Extract whenever the marker is missing OR the entry point is
                // missing. Previously the marker was created before the entry
                // point was verified, so an APK built without server assets
                // left a stale marker behind and Retry could never recover:
                // every retry skipped extraction and failed with the same
                // "Missing .../out/server-main.js" error. A failed or
                // incomplete extraction now removes its own output, so the
                // next attempt (Retry, or the next launch) re-extracts.
                if (!marker.exists() || !entry.isFile) {
                    if (targetDir.exists()) targetDir.deleteRecursively()
                    val copied = copyAssetFolder("flutter_assets/assets/vscode", targetDir)
                    if (copied == 0) {
                        targetDir.deleteRecursively()
                        error("No openvscode-server assets found in this APK (0 files extracted from flutter_assets/assets/vscode). Rebuild the APK with scripts/build-apk.sh so assets/vscode/out/server-main.js is bundled.")
                    }
                    if (!entry.isFile) {
                        targetDir.deleteRecursively()
                        error("Missing ${entry.path} after extracting $copied asset files. Rebuild the APK with scripts/build-apk.sh so openvscode-server assets are bundled.")
                    }
                    // Only mark the extraction complete after the entry
                    // point has been verified to exist on disk.
                    marker.createNewFile()
                }
                val port = (8000..8999).random()
                val token = java.util.UUID.randomUUID().toString().replace("-", "")
                isServerStarted = true
                Thread {
                    startNodeWithArguments(arrayOf(
                        "node", entry.absolutePath, "--host", "127.0.0.1",
                        "--port", port.toString(), "--connection-token", token,
                        "--default-folder", workspace.absolutePath
                    ))
                    isServerStarted = false
                }.start()
                if (!waitForServerReady("127.0.0.1", port)) error("Server did not open port $port")
                runOnUiThread { result.success("http://127.0.0.1:$port/?tkn=$token") }
            } catch (error: Exception) {
                isServerStarted = false
                runOnUiThread { result.error("SERVER_ERROR", error.message, null) }
            }
        }.start()
    }

    // Copies a Flutter asset folder recursively. Returns the number of
    // files copied, so callers can tell an empty asset bundle (an APK
    // built without the openvscode-server assets) apart from a real one.
    private fun copyAssetFolder(assetPath: String, destination: File): Int {
        if (!destination.exists()) destination.mkdirs()
        var copied = 0
        for (name in assets.list(assetPath).orEmpty()) {
            val source = "$assetPath/$name"
            val target = File(destination, name)
            val children = assets.list(source).orEmpty()
            if (children.isNotEmpty()) copied += copyAssetFolder(source, target)
            else {
                assets.open(source).use { input -> FileOutputStream(target).use { input.copyTo(it) } }
                copied++
            }
        }
        return copied
    }

    private fun waitForServerReady(host: String, port: Int): Boolean {
        repeat(60) {
            try { Socket().use { it.connect(InetSocketAddress(host, port), 500); return true } }
            catch (_: Exception) { Thread.sleep(500) }
        }
        return false
    }
}
