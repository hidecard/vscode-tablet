# Android configuration snippets

Add the following inside the existing `android {}` block in `android/app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        ndk { abiFilters += listOf("arm64-v8a") }
    }
    externalNativeBuild {
        cmake { path = file("src/main/cpp/CMakeLists.txt") }
    }
}
```

Add these entries to the existing `AndroidManifest.xml` only after reviewing your storage and distribution policy:

```xml
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
<application android:usesCleartextTraffic="true" ... />
```

For Google Play distribution, prefer the Storage Access Framework instead of broad storage access.
