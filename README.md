# FDSmart - Intelligent Food & Drink Ordering Application 🚀

## ✨ Overview
**FDSmart** is a premium, high-performance Flutter application designed to revolutionize the campus dining experience. It provides a seamless, queue-free ordering system with real-time token tracking, making healthy eating easier and smarter than ever before.

---

## 🌟 Key Features

### 👤 For Students & Staff
- **🔐 Intelligent Authentication**: Secure login and registration with Firebase. Includes a **Demo Mode** fallback for instant testing.
- **🏠 Dynamic Dashboard**: 
    - **Personalized Greetings**: Warm welcomes based on the time of day and user name.
    - **Interactive "Today's Specials"**: View daily deals with direct "Add to Cart" functionality.
- **🥗 Healthy Picks**: Intelligent filtering system to help users find the most nutritious meals effortlessly.
- **🌐 Multi-Language Support**: Fully localized in **English**, **Sinhala**, and **Tamil**.
- **📊 Nutrition Tracker**: Integrated nutrition information and tracking simulation.
- **🛒 Smart Cart & Checkout**: Interactive cart management with instant token generation upon order success.
- **🕒 Real-time Order Tracker**: Follow your order from "Preparing" to "Ready" in real-time.
- **📸 Profile Management**: Update profile details and upload profile photos locally.
- **📶 Offline-Ready UI**: Visual indicators for network status ensuring users always know when they are connected.

### 🛠 For Canteen Admins
- **📊 Centralized Management**: Complete control over orders and the menu through a dedicated admin portal.
- **📦 Order Fulfillment**: Real-time order queue management to update statuses instantly.
- **🍏 Menu Control**: Dynamic menu updates (Add/Edit/Delete) with a toggle for item availability.

---

## 🎨 Design Aesthetics
- **Modern UI**: Dark-themed architecture with an elegant **Off-White** header for accessibility.
- **Rich Interaction**: Smooth micro-animations, glassmorphism overlays, and haptic feedback.
- **Brand Identity**: Consistent color palette (Deep Orange & Amber) reflecting energy and food health.

---

## 🏗 Architecture & Tech Stack
The application follows the **MVVM (Model-View-ViewModel)** architectural pattern for clean separation of concerns and scalability.

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Backend**: [Firebase](https://firebase.google.com/) (Auth, Cloud Firestore)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Storage**: [Hive](https://pub.dev/packages/hive) & [SharedPreferences]
- **Media**: [Image Picker](https://pub.dev/packages/image_picker) for profile photos.
- **Utility**: `connectivity_plus`, `google_fonts`.

---

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK (Latest Stable)
- Dart SDK
- Android Studio / VS Code

### 1. Clone & Install
```bash
git clone https://github.com/salharifan/FDSmart.git
cd FDSmart
flutter pub get
```

### 2. Firebase Configuration
To use live backend features:
1. Create a Firebase Project on the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Email/Password Authentication** and **Cloud Firestore**.
3. Generate your `firebase_options.dart` using the FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

### 3. Run Application
```bash
flutter run
```

---

## 📂 Project Structure
```
lib/
├── core/
│   ├── theme/          # Custom AppTheme, AppColors
│   ├── widgets/        # Universal UI Components (Buttons, Header, Banner)
├── features/
│   ├── admin/          # Admin Dashboard & Fulfillment logic
│   ├── auth/           # Auth logic, Profile, & Multi-language support
│   ├── home/           # Main Dashboard & Interactive Widgets
│   ├── menu/           # Menu Browsing & Detailed Item Views
│   ├── orders/         # Cart, History, & Nutrition Tracking
├── main.dart           # Service locator & Application Entry
```

---

## 🛠 Testing
Validate the application with the built-in test suite:
```bash
flutter test
```

---

## 🔮 Future Roadmap
- [ ] Integration with a live Payment Gateway (Stripe/Payhere).
- [ ] Push Notifications (FCM) for "Order Ready" alerts.
- [ ] Machine Learning based personal dietary recommendations.
- [ ] Real-time canteen occupancy tracker.

---
**Developed with ❤️ by the FDSmart Team**
