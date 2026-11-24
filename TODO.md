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
- [x] `Missing .../out/server-main.js` error ကို ပြင်ပြီးပါပြီ (2026-11-24): extraction marker ကို `server-main.js` ရှိမှ ဖန်တီးအောင်၊ ပျက်တဲ့ extraction ကို ဖျက်ပြီး Retry က ပြန်ကူးနိုင်အောင်၊ `copyAssetFolder` က ကူးတဲ့ ဖိုင်အရေအတွက် ပြန်ပေးအောင် ပြင်ပြီးပါပြီ
- [x] Build/CI က asset မပါတဲ့ APK မထွက်အောင် ပြင်ပြီးပါပြီ: `build-apk.sh` က asset ကို အမြဲ ပြန် fetch + build မလုပ်ခင် စစ်တယ်၊ GitHub Actions မှာ fetch + verify အဆင့် သီးသန့် ထည့်ထားတယ်
- [x] `fetch-openvscode-assets.sh` ရဲ့ tar ownership error ကို ပြင်ပြီးပါပြီ (`--no-same-owner`) — အရင်က root/container မှာ tar က ownership ပြောင်းမရလို့ script က ရပ်ပြီး asset မကူးဘဲ နေခဲ့တယ်
- [x] OpenVSCode Server v1.109.5 bundle ရဲ့ native `.node` တွေကို စစ်ပြီးပါပြီ: အားလုံး glibc (`libc.so.6`) နဲ့ link ထားတယ်၊ main server ကတော့ spdlog load ပျက်တာကို catch လုပ်ပြီး ဆက်ပြီး run နိုင်တယ် (Linux host မှာ Node နဲ့ စမ်းပြီး HTTP 200 ရပြီ) — terminal/watcher native တွေကတော့ Bionic rebuild လိုသေးတယ်

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

- [x] OpenVSCode Server version တစ်ခုကို သတ်မှတ်ပြီး source/build reproducibility ပြုလုပ်ရန် — v1.109.5 (linux-arm64) ကို `scripts/fetch-openvscode-assets.sh` မှာ pin ထားပြီး၊ build တိုင်းမှာ ပြန် fetch + verify လုပ်တယ်
- [x] `out/server-main.js` နှင့် server runtime assets ကို Android asset bundle အဖြစ် assemble လုပ်ရန် — `build-apk.sh` + CI က 1000 ကျော် ဖိုင်ရှိမှ build လုပ်တယ်
- [x] Linux glibc native addons များကို Android Bionic အတွက် စစ်ဆေးရန် — `pty.node`, `spdlog.node`, `watcher.node`, `watchdog.node`, `kerberos.node` အားလုံး `libc.so.6`/`libpthread.so.0` နဲ့ link ထားတာ စစ်ပြီးပြီ; main server က spdlog မလိုဘဲ စတင်နိုင်တာ Linux host မှာ စမ်းသပ်ပြီး အတည်ပြုပြီးပြီ
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
- [x] Storage permission မရလည်း app-private workspace ဖြင့် startup ဆက်လုပ်နိုင်အောင် ပြင်ပြီးပါပြီ
- [x] Pinned OpenVSCode Server asset auto-fetch script ထည့်ပြီးပါပြီ
- [ ] Release APK နှင့် checksums ထုတ်ရန်
- [ ] README တွင် supported devices၊ known issues နှင့် install guide update လုပ်ရန်

## Current blocker

Integrated terminal နှင့် native file watcher အတွက် Android Bionic compatible native addons (`node-pty`, `@parcel/watcher`) မရှိသေးပါ — အဲ့တာတွေ rebuild လုပ်ပြီးမှ terminal/watcher အပြည့်အစုံ ရမည်။ Editor ကိုယ်တိုင်ကတော့ အဲ့ဒီ native modules မပါဘဲ စတင်နိုင်သည် (spdlog load ပျက်တာကို catch လုပ်ထားသည်)။ အဟောင်း APK ကို tablet မှာ install လုပ်ထားသေးရင် uninstall လုပ်ပြီးမှ APK အသစ် install လုပ်ပါ — အဟောင်း app data ထဲက stale extraction ရှိနေနိုင်သည်။

အဟောင်း APK (2026-11-24 မတိုင်ခင် build) မှာ ဖြစ်ခဲ့တဲ့ `Missing .../out/server-main.js` error ကတော့ ဒီ branch မှာ ပြင်ပြီးပြီ: build က asset ကို verify လုပ်ပြီးမှ APK ထုတ်တယ်၊ app က marker ကို verify ပြီးမှ ဖန်တီးတယ်။
