# TRADE-WITH-AI

Auto trading system with AI-powered features and Firebase backend integration.

## Features

- 🔐 Firebase Authentication
- 📊 Real-time Trading Data with Cloud Firestore
- 💾 Cloud Storage for media and documents
- 📈 Analytics and insights
- 🤖 AI-powered trading suggestions (coming soon)

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase CLI (optional but recommended)

## Firebase Setup

This project uses Firebase as the backend. You need to configure Firebase before running the app.

### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the setup wizard
3. Enable the following Firebase services:
   - Authentication (Email/Password, Google Sign-In)
   - Cloud Firestore
   - Cloud Storage
   - Analytics

### Step 2: Configure Firebase for Android

1. In Firebase Console, add an Android app to your project
2. Register your app with package name: `com.example.trade_with_ai`
3. Download the `google-services.json` file
4. Place it in `android/app/google-services.json`

### Step 3: Configure Firebase for iOS

1. In Firebase Console, add an iOS app to your project
2. Register your app with bundle ID: `com.example.tradeWithAi`
3. Download the `GoogleService-Info.plist` file
4. Place it in `ios/Runner/GoogleService-Info.plist`

### Step 4: Configure Firebase Options

1. Install FlutterFire CLI (recommended):
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Run the configuration command:
   ```bash
   flutterfire configure
   ```
   
   This will automatically generate the `lib/firebase_options.dart` file with your Firebase configuration.

   **OR**

3. Manually update `lib/firebase_options.dart` with your Firebase project credentials from the Firebase Console:
   - Replace `YOUR_WEB_API_KEY` with your Web API Key
   - Replace `YOUR_ANDROID_API_KEY` with your Android API Key
   - Replace `YOUR_IOS_API_KEY` with your iOS API Key
   - Replace `YOUR_PROJECT_ID` with your Firebase Project ID
   - Replace other placeholder values with actual values from Firebase Console

### Step 5: Update Firebase Security Rules

Set up security rules in Firebase Console for Firestore and Storage to control access to your data.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/GAGAN7350/TRADE-WITH-AI.git
   cd TRADE-WITH-AI
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # Entry point with Firebase initialization
├── firebase_options.dart     # Firebase configuration (auto-generated)
└── screens/
    └── home_screen.dart      # Main home screen

android/                      # Android-specific configuration
├── app/
│   ├── build.gradle         # Android build config with Firebase
│   ├── google-services.json # Firebase config (add your own)
│   └── google-services.json.template  # Template for reference
└── build.gradle             # Project-level build config

ios/                         # iOS-specific configuration
└── Runner/
    ├── Info.plist          # iOS app configuration
    └── GoogleService-Info.plist  # Firebase config (add your own)
```

## Configuration Files

### Important Files (Not Committed to Git)

The following files contain sensitive API keys and should be added by you:

1. `android/app/google-services.json` - Download from Firebase Console
2. `ios/Runner/GoogleService-Info.plist` - Download from Firebase Console
3. `lib/firebase_options.dart` - Generate using FlutterFire CLI or manually configure

Template files are provided for reference:
- `android/app/google-services.json.template`

## Development

### Running Tests

```bash
flutter test
```

### Building for Production

**Android:**
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## Troubleshooting

### Firebase not initialized error
- Ensure you've added the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files
- Verify that `firebase_options.dart` has correct configuration
- Run `flutter clean` and `flutter pub get`

### Build errors on Android
- Check that you have the latest Android SDK
- Ensure Google Services plugin is properly configured in `android/build.gradle`
- Verify minimum SDK version is 21 or higher

### Build errors on iOS
- Run `pod install` in the `ios/` directory
- Ensure you have a valid provisioning profile

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See the [LICENSE](LICENSE) file for details.

## Support

For issues and questions, please open an issue on GitHub.

---

**Note:** Remember to never commit your Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`, or actual `firebase_options.dart` with real API keys) to version control. These files are listed in `.gitignore` for security.
