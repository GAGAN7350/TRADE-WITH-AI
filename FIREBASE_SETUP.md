# Firebase Setup Guide

This guide will help you set up Firebase backend for the Trade With AI application.

## Prerequisites

- A Google account
- Access to [Firebase Console](https://console.firebase.google.com/)
- Flutter SDK installed on your machine
- FlutterFire CLI (optional but recommended)

## Step-by-Step Setup

### 1. Create Firebase Project

1. Visit [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `trade-with-ai` (or your preferred name)
4. Enable/disable Google Analytics (recommended to enable)
5. Click **"Create project"** and wait for setup to complete

### 2. Enable Firebase Services

#### Authentication
1. In Firebase Console, go to **Build** → **Authentication**
2. Click **"Get started"**
3. Enable **Email/Password** sign-in method
4. (Optional) Enable **Google Sign-In** and other providers as needed

#### Cloud Firestore
1. Go to **Build** → **Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in test mode"** for development (update security rules later)
4. Select a Cloud Firestore location closest to your users
5. Click **"Enable"**

#### Cloud Storage
1. Go to **Build** → **Storage**
2. Click **"Get started"**
3. Start in **test mode** for development
4. Click **"Done"**

#### Analytics (Optional)
- Analytics should be automatically enabled if you chose to enable it during project creation

### 3. Register Your App

#### For Android

1. In Firebase Console, click **"Add app"** → Select **Android** icon
2. Register app with package name: `com.example.trade_with_ai`
3. (Optional) Add app nickname: `Trade With AI Android`
4. Click **"Register app"**
5. Download `google-services.json` file
6. Place the file in: `android/app/google-services.json`
7. Follow Firebase instructions to update your build files (already done in this project)
8. Click **"Continue to console"**

#### For iOS

1. In Firebase Console, click **"Add app"** → Select **iOS** icon
2. Register app with bundle ID: `com.example.tradeWithAi`
3. (Optional) Add app nickname: `Trade With AI iOS`
4. Click **"Register app"**
5. Download `GoogleService-Info.plist` file
6. Place the file in: `ios/Runner/GoogleService-Info.plist`
7. Follow Firebase instructions (CocoaPods are already configured in this project)
8. Click **"Continue to console"**

#### For Web

1. In Firebase Console, click **"Add app"** → Select **Web** icon (</> symbol)
2. Register app nickname: `Trade With AI Web`
3. Click **"Register app"**
4. Copy the Firebase configuration object (you'll need this for the next step)

### 4. Configure Firebase Options

#### Option A: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Configure your project:
   ```bash
   flutterfire configure
   ```

4. Select your Firebase project from the list
5. Select platforms you want to configure (Android, iOS, Web)
6. The CLI will automatically generate `lib/firebase_options.dart` with your configuration

#### Option B: Manual Configuration

1. Open `lib/firebase_options.dart`
2. Replace the placeholder values with your actual Firebase configuration:

   **For Web:**
   - Go to Firebase Console → Project Settings → Your apps → Web app
   - Copy the configuration values and replace in the `web` section

   **For Android:**
   - The values from `google-services.json` or Firebase Console → Project Settings → Your apps → Android app
   - Replace in the `android` section

   **For iOS:**
   - The values from `GoogleService-Info.plist` or Firebase Console → Project Settings → Your apps → iOS app
   - Replace in the `ios` section

   Example:
   ```dart
   static const FirebaseOptions android = FirebaseOptions(
     apiKey: 'AIzaSyABC123...',  // Your actual API key
     appId: '1:123456789:android:abc123...',  // Your actual app ID
     messagingSenderId: '123456789',  // Your sender ID
     projectId: 'trade-with-ai',  // Your project ID
     storageBucket: 'trade-with-ai.appspot.com',
   );
   ```

### 5. Update Security Rules

#### Firestore Rules
1. Go to **Firestore Database** → **Rules**
2. Update rules for production (example):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Trade positions
    match /trades/{tradeId} {
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && 
                              resource.data.userId == request.auth.uid;
    }
  }
}
```

3. Click **"Publish"**

#### Storage Rules
1. Go to **Storage** → **Rules**
2. Update rules for production (example):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. Click **"Publish"**

### 6. Set Up Indexes (Optional)

If your app requires complex queries, you may need to create composite indexes:

1. Go to **Firestore Database** → **Indexes**
2. Click **"Add index"** as needed for your queries
3. Alternatively, run your app and Firebase will suggest indexes when needed

### 7. Configure App Check (Optional, for production)

App Check helps protect your backend resources from abuse:

1. Go to **Build** → **App Check**
2. Register your app for each platform
3. For Android: Use Play Integrity API
4. For iOS: Use DeviceCheck or App Attest
5. For Web: Use reCAPTCHA

## Testing Your Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

3. Check for any Firebase initialization errors in the console

4. Test authentication, Firestore, and Storage features

## Troubleshooting

### "FirebaseOptions have not been configured"
- Ensure `lib/firebase_options.dart` has correct configuration
- Make sure you've added platform-specific config files

### Android build errors
- Verify `google-services.json` is in `android/app/` directory
- Check that Google Services plugin is in `android/build.gradle`
- Ensure minimum SDK version is 21+

### iOS build errors
- Verify `GoogleService-Info.plist` is in `ios/Runner/` directory
- Run `pod install` in the `ios/` directory
- Check Xcode for any signing issues

### Web not working
- Ensure Firebase SDK scripts are loaded in `web/index.html`
- Check browser console for CORS or configuration errors
- Verify Web app is registered in Firebase Console

## Security Best Practices

1. **Never commit sensitive files:**
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `lib/firebase_options.dart` (with real keys)

2. **Use environment-specific configurations:**
   - Separate Firebase projects for development, staging, and production

3. **Update security rules:**
   - Change from test mode to production rules before launch
   - Regularly review and update rules

4. **Enable App Check:**
   - Protect your backend from unauthorized access

5. **Monitor usage:**
   - Set up budget alerts in Firebase Console
   - Monitor authentication, database, and storage usage

## Next Steps

After completing the Firebase setup:

1. Run the app and test Firebase features
2. Implement additional authentication methods if needed
3. Create your data models and Firestore structure
4. Set up Cloud Functions for backend logic (if needed)
5. Configure push notifications with Firebase Cloud Messaging
6. Set up remote configuration with Firebase Remote Config

## Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

---

For issues specific to this project, please open an issue on GitHub.
