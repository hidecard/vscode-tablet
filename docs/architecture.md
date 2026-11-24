# Architecture

```text
Flutter UI
   │ MethodChannel: com.example.tablet_vscode/server
   ▼
MainActivity.kt ── extracts assets/vscode → filesDir/vscode
   │ JNI
   ▼
native-lib.cpp ── calls node::Start()
   │
libnode.so (arm64-v8a) ── runs out/server-main.js
   │ localhost:8080
   ▼
InAppWebView
```

The app intentionally targets `arm64-v8a` first. The server bundle and native Node.js modules must be rebuilt or verified for Android Bionic; Linux glibc `.node` files are not safe to reuse on Android.
