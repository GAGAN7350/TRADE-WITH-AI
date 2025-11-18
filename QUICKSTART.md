# Quick Start Guide

Get your Trade With AI app running in minutes!

## Prerequisites

- [ ] Flutter SDK installed ([Install Flutter](https://docs.flutter.dev/get-started/install))
- [ ] Android Studio / Xcode installed (for mobile development)
- [ ] Google account for Firebase

## Steps

### 1. Clone & Install (2 minutes)

```bash
git clone https://github.com/GAGAN7350/TRADE-WITH-AI.git
cd TRADE-WITH-AI
flutter pub get
```

### 2. Firebase Setup (10-15 minutes)

#### Quick Option: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure your project (this creates everything automatically!)
flutterfire configure
```

The CLI will:
- Create a Firebase project (or let you select existing one)
- Register your app for Android, iOS, and Web
- Generate `lib/firebase_options.dart` with your configuration
- You'll still need to enable services in Firebase Console

#### Manual Option: Follow Detailed Guide

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for step-by-step instructions.

### 3. Enable Firebase Services (5 minutes)

In [Firebase Console](https://console.firebase.google.com/):

1. **Authentication** → Enable "Email/Password"
2. **Firestore Database** → Create database (start in test mode)
3. **Storage** → Get started (start in test mode)

### 4. Run the App! (1 minute)

```bash
# For Android
flutter run -d android

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

## What You Get

- ✅ Complete Flutter project structure
- ✅ Firebase integration (Auth, Firestore, Storage)
- ✅ Authentication service
- ✅ Database service
- ✅ Sample home screen
- ✅ Data models for trading
- ✅ Cross-platform support (Android, iOS, Web)

## Next Steps

1. **Customize the UI** in `lib/screens/home_screen.dart`
2. **Add trading features** using the service layer
3. **Configure security rules** in Firebase Console
4. **Add more data models** in `lib/models/`
5. **Build and deploy** to your platform of choice

## Common Issues

### "Firebase not initialized"
- Make sure you ran `flutterfire configure` OR manually configured firebase_options.dart
- Check that firebase_options.dart has real values, not placeholders

### Android build errors
- Ensure you have Android SDK 21 or higher
- Run `flutter clean` then `flutter pub get`

### iOS build errors
- Run `pod install` in the `ios/` directory
- Make sure Xcode is up to date

## Need Help?

- 📖 [Full Documentation](README.md)
- 🔥 [Firebase Setup Guide](FIREBASE_SETUP.md)
- 🤝 [Contributing Guide](CONTRIBUTING.md)
- 🐛 [Report Issues](https://github.com/GAGAN7350/TRADE-WITH-AI/issues)

## Development Tips

```bash
# Run analyzer
flutter analyze

# Format code
flutter format .

# Run tests
flutter test

# Build for production
flutter build apk           # Android
flutter build ios           # iOS
flutter build web           # Web
```

---

**Estimated total setup time:** 15-20 minutes

Happy coding! 🚀
