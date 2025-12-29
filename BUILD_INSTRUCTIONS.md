# FDSmart
Build Instructions and Release Documentation

### 1. Issue Identification and Resolution
### 1.1 Problem Description

The initial release of the application was compiled for the x86_64 architecture, which is intended for Android emulators. Physical Android devices predominantly operate on ARM-based architectures. As a result, the application failed to execute on real devices and produced the following runtime error:

* ```Could not find 'libflutter.so'.```
* ```Looked for: [arm64-v8a, armeabi-v7a, armeabi]```
* ```Found only: [x86_64]```

### 1.2 Root Cause

The error occurred due to an architecture mismatch between the generated APK and the target device hardware.

### 1.3 Resolution

A new release build was generated targeting ARM-compatible architectures, specifically:

* arm64-v8a
* armeabi-v7a

This ensures compatibility with both modern and legacy Android devices.

### 2. Release Artifacts
### 2.1 Release APK (Direct Installation)

- File Path:
```build/app/outputs/flutter-apk/app-release.apk```

- File Size: ```36.8 MB```

- Target Architectures: ```ARM64 and ARM32```

- Purpose: Direct installation and functional testing on physical Android devices

### 2.2 Android App Bundle (AAB)

- File Path:
```build/app/outputs/bundle/release/app-release.aab```

- File Size: ```47.6 MB```

- Target Architectures: All supported architectures

- Purpose: Deployment via Google Play Store

Advantage: Google Play dynamically delivers optimized APKs for each device configuration

### 3. Installation Procedures
### 3.1 Manual APK Installation

- Connect the Android device to a personal computer using a USB cable

- Transfer app-release.apk to the device storage

- Locate the APK file using a file manager

- Enable installation from unknown sources if prompted

- Complete the installation and launch the application

### 3.2 Installation via Android Debug Bridge (ADB)
- ```adb install``` build/app/outputs/flutter-apk/app-release.apk

- Note: USB Debugging must be enabled on the target device.

### 4. Build Environment and Commands
### 4.1 Project Cleanup
- ```flutter clean```
- ```flutter pub get```

### 4.2 APK Build for ARM Architectures
- ```flutter build apk --release --target-platform android-arm,android-arm64```

### 4.3 App Bundle Generation
- ```flutter build appbundle --release```

### 5. Device Compatibility

- The release build supports:

- ARM64-based Android devices

- ARM32-based Android devices

- Android operating system version 5.0 (Lollipop) and above

### 6. Code Quality Assessment

Static analysis identified 41 minor lint warnings, primarily related to:

- Deprecated API usage

- Code style recommendations

These issues do not impact application functionality and do not affect runtime behavior.

### 7. Functional Scope of the Application

The FDSmart application provides the following features:

- Firebase-based authentication (user login and registration)

- Home interface with dynamic product listings

- Cart and order management system

- Order tracking functionality

- User profile and settings management

- Notification handling

- Review and rating system

- Administrative dashboard

- Modern Material Design–based user interface

### 8. Recommended Next Steps

- Install the release APK on a physical Android device

- Perform end-to-end functional testing

- Upload the App Bundle (.aab) to Google Play Store for production deployment

### 9. Usage Notes

- Initial application launch may take several seconds due to service initialization

- An active internet connection is required for Firebase-dependent features

- Users should grant requested permissions during first use

### 10. Troubleshooting Guidelines

If installation or runtime issues persist:

- Uninstall any previously installed versions of the application

- Clear application cache and data

- Restart the Android device

- Reinstall the latest release APK

### 11. Build Metadata

```Build Date: 24 December 2025, 11:55 PM (IST)```

```Application Version: 1.0.0+1```

```Flutter Channel: Stable```

```Target SDK: Android 14```