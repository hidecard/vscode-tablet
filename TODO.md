# VS Code Tablet — TODO

ဒီဖိုင်က repository ရဲ့ ကျန်ရှိနေတဲ့ အလုပ်များကို အဆင့်လိုက်မှတ်တမ်းတင်ထားတာပါ။

## Completed

- [x] Flutter loading UI နှင့် WebView shell ရေးပြီးပါပြီ
- [x] Kotlin `MethodChannel` ဖြင့် server start flow ချိတ်ပြီးပါပြီ
- [x] JNI C++ bridge ဖြင့် `node::Start()` ခေါ်နိုင်အောင် ရေးပြီးပါပြီ
- [x] `arm64-v8a` အတွက် CMake import configuration ထည့်ပြီးပါပြီ
- [x] First-run VS Code asset extraction logic ထည့်ပြီးပါပြီ
- [x] Server port `8080` readiness polling နှင့် error timeout ထည့်ပြီးပါပြီ
- [x] GitHub public repository၊ README၊ description နှင့် topics ပြင်ဆင်ပြီးပါပြီ
- [x] Official Node.js Mobile Android runtime download script ထည့်ပြီးပါပြီ
- [x] Node.js Mobile `libnode.so` ကို local staging အဖြစ် download စမ်းသပ်ပြီးပါပြီ
- [x] CMake တွင် official Node.js headers include path ထည့်ပြီးပါပြီ
- [x] Source wiring verification script ထည့်ပြီးပါပြီ

## Phase 1 — Flutter Android project completion

- [ ] Flutter SDK ထည့်သွင်းပြီး `flutter create` ဖြင့် complete Android project wrapper ဖန်တီးရန်
- [ ] `android/app/build.gradle(.kts)` ထဲတွင် `arm64-v8a` ABI filter ထည့်ရန်
- [ ] `externalNativeBuild.cmake` configuration ထည့်ရန်
- [ ] `flutter_inappwebview` နှင့် `permission_handler` dependency versions ကို resolve လုပ်ရန်
- [ ] `AndroidManifest.xml` တွင် `INTERNET` permission ထည့်ရန်
- [ ] Storage Access Framework ကို broad `MANAGE_EXTERNAL_STORAGE` permission အစား စဉ်းစားရန်
- [ ] Android minimum SDK၊ target SDK နှင့် NDK version သတ်မှတ်ရန်
- [ ] Debug APK ကို arm64 Android tablet တစ်လုံးပေါ်တွင် install စမ်းရန်

## Phase 2 — Node.js runtime verification

- [x] `scripts/fetch-nodejs-mobile.sh` ဖြင့် runtime download/staging ကို local environment တွင် စမ်းပြီးပါပြီ
- [x] `libnode.so` ၏ arm64 ELF ABI ကို စစ်ပြီးပါပြီ
- [ ] Android NDK/CMake build ဖြင့် `native-lib.so` ကို compile စမ်းရန်
- [ ] `node::Start()` ကို သီးခြား hello-world Node script ဖြင့် စမ်းရန်
- [ ] Node thread crash ဖြစ်ပါက logcat diagnostics ထည့်ရန်
- [ ] App background/foreground ပြောင်းချိန်တွင် Node server lifecycle ကို စီမံရန်
- [ ] App ပိတ်ချိန်တွင် Node server ကို graceful shutdown လုပ်ရန်

## Phase 3 — OpenVSCode Server Android port

- [ ] OpenVSCode Server version တစ်ခုကို သတ်မှတ်ပြီး source/build reproducibility ပြုလုပ်ရန်
- [ ] `out/server-main.js` နှင့် server runtime assets ကို Android asset bundle အဖြစ် assemble လုပ်ရန်
- [ ] Linux glibc native addons များကို Android Bionic အတွက် စစ်ဆေးရန်
- [ ] `node-pty` ကို Android NDK ဖြင့် ပြန် build သို့မဟုတ် Android-compatible alternative ဖြင့် အစားထိုးရန်
- [ ] `@vscode/spdlog` နှင့် အခြား `.node` native modules များကို ပြန် build/replace လုပ်ရန်
- [ ] `server-main.js` ၏ file paths၊ temp paths နှင့် process spawning behavior ကို Android နှင့် ကိုက်ညီအောင် patch လုပ်ရန်
- [ ] `--host 127.0.0.1`၊ `--port 8080` နှင့် connection-token policy ကို စမ်းရန်
- [ ] Server bundle ကို APK size မကြီးလွန်းအောင် compress/extract strategy ပြုလုပ်ရန်
- [ ] Third-party licenses နှင့် OpenVSCode Server notices ကို APK ထဲ ထည့်ရန်

## Phase 4 — Tablet UX and storage

- [ ] Landscape/portrait tablet layouts စမ်းရန်
- [x] Hardware back button ကို WebView history နှင့် ချိတ်ပြီးပါပြီ
- [ ] Keyboard၊ mouse၊ stylus input စမ်းရန်
- [ ] User workspace folder ရွေးချယ်ရန် Storage Access Framework UI ထည့်ရန်
- [x] Permission denied နှင့် server start failure အတွက် retry screen ထည့်ပြီးပါပြီ
- [ ] Offline first-launch progress နှင့် extraction progress ပြရန်
- [ ] Screen rotation ပြောင်းချိန်တွင် WebView/server state မပျောက်အောင် ထိန်းရန်

## Phase 5 — Testing and release

- [ ] Unit tests: argument conversion နှင့် server state handling
- [ ] Integration test: app launch → asset extraction → port ready → WebView
- [ ] Physical arm64 tablet များတွင် Android 8, 10, 12, 14 စမ်းရန်
- [ ] APK size၊ startup time၊ RAM usage နှင့် battery usage တိုင်းရန်
- [ ] Release signing configuration ထည့်ရန်
- [ ] ProGuard/R8 rules နှင့် native library packaging စစ်ရန်
- [x] GitHub Actions တွင် source wiring verification workflow ထည့်ပြီးပါပြီ
- [x] Local arm64 APK build script ထည့်ပြီးပါပြီ
- [x] GitHub Actions arm64 APK artifact workflow ထည့်ပြီးပါပြီ
- [x] GitHub Actions မှ actual arm64 release APK build နှင့် artifact download ကို verify လုပ်ပြီးပါပြီ
- [ ] Release APK နှင့် checksums ထုတ်ရန်
- [ ] README တွင် supported devices၊ known issues နှင့် install guide update လုပ်ရန်

## Current blocker

OpenVSCode Server upstream release artifacts များသည် Linux/Docker အတွက် ဖြစ်သောကြောင့် Android APK ထဲသို့ တိုက်ရိုက်ထည့်၍ မရသေးပါ။ Android Bionic compatible server bundle နှင့် native addons ရရှိပြီးမှ standalone APK ကို အပြည့်အစုံ build/run လုပ်နိုင်ပါမည်။
