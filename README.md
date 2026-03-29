# SkyFit Pro (TheBid Secure Vault)

A secure, MVVM-based Flutter application for fitness tracking and authenticated vault management. This project integrates Firebase for backend services, biometric authentication for security, and real-time weather-based activity suggestions.

---

## 👥 Team Members & Roles

| Name | Role |
| :--- | :--- |
| **Jian Carpio** | Lead Architect & Navigation |
| **Albert Jhun Cañedo** | 	Security & Biometrics |
| **David Mataytay** | Profile & Logic |
| **Alyssa Monzon** | UI/UX Integration |
| **Christian Jay Capuyan** | DevOps & Cloud (GCP) |

---

## ✨ Features

- **Multi-Factor Authentication**: Email/Password, Google Sign-In, and Facebook Login.
- **Biometric Security**: Fingerprint/Face ID integration using `local_auth`.
- **MVVM Architecture**: Clean separation of concerns for maintainability.
- **Fitness Dashboard**: Track water intake, workouts, and progress.
- **Weather Integration**: Dynamic activity suggestions based on local weather conditions.
- **Secure Storage**: Sensitive data encrypted using `flutter_secure_storage`.
- **Push Notifications**: Real-time alerts via Firebase Cloud Messaging (FCM).
- **Dark Mode**: Fully adaptive theme support.

---

## 🚀 How to Run Locally

### Prerequisites

1.  **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install) (v3.10.8 or higher recommended).
2.  **Firebase CLI**: [Install Firebase CLI](https://firebase.google.com/docs/cli) and log in (`firebase login`).
3.  **Java SDK**: Required for Android builds.
4.  **CocoaPods**: Required for iOS builds (macOS only).

### Step 1: Clone the Repository

```bash
git clone https://github.com/canedoalbert6-droid/thebid-secure-vault.git
cd secure_auth_mvvm
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Firebase Setup

This project requires a Firebase project. 

1.  Create a new project in the [Firebase Console](https://console.firebase.google.com/).
2.  Enable **Authentication** (Email/Password, Google, Facebook).
3.  Enable **Cloud Firestore** and **Firebase Storage**.
4.  Configure your apps using the FlutterFire CLI:
    ```bash
    dart pub global activate flutterfire_cli
    flutterfire configure
    ```
5.  This will update `lib/firebase_options.dart` with your project credentials.

### Step 4: Configure Social Logins (Optional)

- **Google Sign-In**: Add your SHA-1 fingerprint to the Firebase Android settings.
- **Facebook Login**: Follow the [flutter_facebook_auth](https://pub.dev/packages/flutter_facebook_auth) documentation to set up your Facebook App ID.

### Step 5: Run the App

Connect a device or start an emulator, then run:

```bash
flutter run
```

---

## 🛠 Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)
- **Security**: Local Auth, Flutter Secure Storage
- **UI/UX**: Google Fonts, Flutter Animate, Shimmer

---

## 🔐 Security Best Practices

This application implements several industry-standard security measures:
- **Biometric Binding**: Biometric tokens are unique to the device and tied to the user's Firebase UID.
- **Secure Storage**: Sensitive credentials (passwords, tokens) are never stored in plain text; they use `flutter_secure_storage` which utilizes Keychain (iOS) and AES encryption (Android).
- **Session Management**: Implements a `UserInteractionListener` to track user activity and handle potential session timeouts.
- **Root/Jailbreak Detection**: (Planned) To prevent running on compromised devices.

---

## 🧪 Testing

To run the automated tests:

```bash
flutter test
```

---

## 📂 Project Structure

- `lib/models`: Data structures.
- `lib/views`: UI components and screens.
- `lib/viewmodels`: Business logic and state handling.
- `lib/services`: External API and Firebase integrations.
- `lib/repositories`: Data abstraction layer.
- `lib/utils`: Helpers, themes, and constants.
