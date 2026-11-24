import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: StandaloneVSCodeApp()));
}

class StandaloneVSCodeApp extends StatefulWidget {
  const StandaloneVSCodeApp({super.key});
  @override
  State<StandaloneVSCodeApp> createState() => _StandaloneVSCodeAppState();
}

class _StandaloneVSCodeAppState extends State<StandaloneVSCodeApp> {
  static const platform = MethodChannel('com.example.tablet_vscode/server');
  String? serverUrl;
  String statusText = 'Initializing VS Code engine...';

  @override
  void initState() {
    super.initState();
    _initEnvironment();
  }

  Future<void> _initEnvironment() async {
    final storage = await Permission.manageExternalStorage.request();
    if (!storage.isGranted && mounted) {
      setState(() => statusText = 'Storage permission is required to open folders.');
      return;
    }
    if (mounted) setState(() => statusText = 'Starting local Node.js server...');
    try {
      final url = await platform.invokeMethod<String>('startVSCodeServer');
      if (url == null || url.isEmpty) throw PlatformException(code: 'EMPTY_URL');
      if (mounted) setState(() => serverUrl = url);
    } on PlatformException catch (error) {
      if (mounted) setState(() => statusText = 'Failed to start: ${error.message ?? error.code}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (serverUrl == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(color: Color(0xFF007ACC)),
          const SizedBox(height: 16),
          Text(statusText, style: const TextStyle(color: Colors.white70, fontSize: 15)),
        ])),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(serverUrl!)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true, domStorageEnabled: true, useWideViewPort: true,
          supportZoom: false, mediaPlaybackRequiresUserGesture: false,
        ),
      )),
    );
  }
}
