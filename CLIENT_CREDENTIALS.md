# Backpackers App - Client Credentials & Keys

This document contains all the sensitive credentials and keys needed to build and update the app.

---

## Android Keystore Credentials

### Keystore File
- **File Name:** `upload-keystore.jks`
- **Location:** Root directory of the project
- **Purpose:** Used to sign release builds for Google Play Store

### Keystore Passwords
- **Store Password:** `backpack2025`
- **Key Password:** `backpack2025`
- **Key Alias:** `upload`

### Configuration File
- **File Name:** `key.properties`
- **Location:** Root directory of the project
- **Contents:**
  ```
  storePassword=backpack2025
  keyPassword=backpack2025
  keyAlias=upload
  storeFile=../../upload-keystore.jks
  ```

---

## Firebase Configuration

### Project Information
- **Project ID:** `backpackers-aa063`
- **Project Number:** `876051167584`
- **Storage Bucket:** `backpackers-aa063.appspot.com`

### Firebase Config File
- **File Name:** `google-services.json`
- **Location:** `android/app/google-services.json`
- **Package Name:** `com.backpackers.app`
- **API Key:** `AIzaSyC-L-6O-m6ulqrooSerJvseb-MDnAMh0w0`

### Firebase Project Config
- **File Name:** `.firebaserc`
- **Location:** Root directory
- **Default Project:** `backpackers-aa063`

---

## Build Information

### Current Version
- **Version Code:** `2`
- **Version Name:** `1.0.0`
- **Package Name:** `com.backpackers.app`

### Build Commands

#### For APK (Testing):
```bash
flutter build apk --release
```

#### For AAB (Play Store):
```bash
flutter build appbundle --release
```

**Output Locations:**
- APK: `build/app/outputs/apk/release/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

---

## Important Notes

1. **Keystore Security:**
   - The keystore file (`upload-keystore.jks`) is critical for Play Store updates
   - **NEVER** lose this file - you cannot update the app on Play Store without it
   - Keep a secure backup of the keystore file
   - If the keystore is lost, you'll need to reset the upload key in Play Console (takes 7 days)

2. **Password Security:**
   - All passwords are currently set to: `backpack2025`
   - Consider changing passwords for production use
   - Store passwords securely (password manager recommended)

3. **Firebase Access:**
   - To deploy Cloud Functions, you need Firebase CLI access
   - Ensure you have proper IAM permissions in Google Cloud Console
   - Project owner email: `backpackbuddytravel@gmail.com`

4. **Version Updates:**
   - Always increment `versionCode` in `pubspec.yaml` before building for Play Store
   - Current version code: `2`
   - Next version should be: `3`, then `4`, etc.

---

## Files to Send to Client

The following files are **NOT** in GitHub and must be provided to the client:

### Required Files:
1. ✅ `upload-keystore.jks` - Android signing keystore
2. ✅ `key.properties` - Keystore configuration
3. ✅ `android/app/google-services.json` - Firebase configuration
4. ✅ `.firebaserc` - Firebase project reference
5. ✅ `firebase.json` - Firebase deployment config

### Optional (if client needs to deploy Cloud Functions):
6. ⚠️ `functions/package.json` - Cloud Functions dependencies
7. ⚠️ `functions/index.js` - Cloud Functions code

---

## Quick Setup Instructions for Client

1. **Place keystore file:**
   - Copy `upload-keystore.jks` to the project root directory

2. **Place key.properties:**
   - Copy `key.properties` to the project root directory
   - Verify the path in `storeFile` matches your setup

3. **Place Firebase config:**
   - Copy `google-services.json` to `android/app/google-services.json`
   - Copy `.firebaserc` to project root
   - Copy `firebase.json` to project root

4. **Build the app:**
   ```bash
   flutter pub get
   flutter build appbundle --release
   ```

5. **Upload to Play Store:**
   - Go to Google Play Console
   - Navigate to your app
   - Go to "Production" or "Internal testing" track
   - Upload the AAB file from `build/app/outputs/bundle/release/app-release.aab`

---

## Support Contacts

- **Project Owner:** backpackbuddytravel@gmail.com
- **Firebase Project:** backpackers-aa063

---

**Last Updated:** November 2025
**Document Version:** 1.0



