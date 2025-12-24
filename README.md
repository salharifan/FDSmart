# FDSmart - Intelligent Food & Drink Ordering Application

## Overview
FDSmart is a Flutter-based cross-platform mobile application designed to provide a smart, queue-free canteen ordering token tracking experience. It connects Students/Staff with Canteen Administrators for seamless food ordering.

## Features

### User (Student/Staff)
- **Authentication**: secure Login & Registration (Firebase Auth).
- **Home Dashboard**: View specials, navigating to Menu, Orders, Profile.
- **Menu Browsing**: Filtered view for Food and Drinks with details.
- **Order Placement**: Add to cart, review tokens, and confirm order.
- **Real-time Tracking**: View order status (Preparing -> Ready -> Completed).
- **Offline Mode**: View cached menu data when offline (Connectivity Plus + Hive/Cache).

### Admin (Canteen Staff)
- **Admin Dashboard**: Switch between Orders and Menu management.
- **Order Management**: View active orders, update status (Preparing/Ready/Completed) in real-time.
- **Menu Management**: Add, Edit, Delete, and Toggle availability of items.

## Architecture
The application follows the **MVVM (Model-View-ViewModel)** architectural pattern.

- **Model**: Data structures (`user_model.dart`, `menu_item_model.dart`, `order_model.dart`).
- **View**: UI Screens (`LoginScreen`, `HomeScreen`, `MenuScreen`, etc.).
- **ViewModel**: Business Logic & State Management (`AuthViewModel`, `MenuViewModel`, `OrderViewModel`).
- **Services**: Firebase (Firestore, Auth), Connectivity.

### State Management
- **Provider**: Used for dependency injection and state management across ViewModels.

## Technology Stack
- **Framework**: Flutter (Dart)
- **Backend**: Firebase (Auth, Firestore)
- **Local Storage**: Hive (Planned integration for deep caching), Connectivity Plus
- **Styling**: Custom Theme (Dark Mode, Outfit Font)

## Setup Instructions

1.  **Prerequisites**: Flutter SDK, Dart, Android Studio / VS Code.
2.  **Firebase Setup**:
    -   Create a Firebase Project.
    -   Enable Authentication (Email/Password).
    -   Enable Cloud Firestore.
    -   Run `flutterfire configure` to generate `firebase_options.dart`.
    -   Currently, a dummy `firebase_options.dart` is provided. **You MUST replace it.**
3.  **Run Application**:
    ```bash
    flutter pub get
    flutter run
    ```
4.  **Build APK**:
    ```bash
    flutter build apk
    ```

## Folder Structure
```
lib/
├── core/
│   ├── constants/
│   ├── theme/          # AppTheme, AppColors
│   ├── widgets/        # Reusable widgets (Buttons, TextFields, OfflineBanner)
├── features/
│   ├── admin/          # Admin Dashboard & Logic
│   ├── auth/           # Login/Register Screens & Logic
│   ├── home/           # Dashboard Screen & Widgets
│   ├── menu/           # Menu Listing, Details, ViewModel
│   ├── orders/         # Order History, Placement, ViewModel
├── main.dart           # Entry point & Providers
└── firebase_options.dart # Firebase Config (Needs Update)
```

## Testing
- Unit & Widget tests are located in `test/`.
- Run `flutter test` to execute.

## Future Enhancements
- Deep Hive integration for full offline cart persistence.
- Push Notifications (FCM) for order status updates.
- Payment Gateway integration.
