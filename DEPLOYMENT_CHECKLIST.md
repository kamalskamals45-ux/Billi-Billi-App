# Billi Billi — Final Firebase Deployment Checklist

This package keeps the v13 application source unchanged and adds this deployment checklist.

## 1. Firebase billing / Storage
- Open Firebase Console for project `billi-billi-video`.
- Upgrade the project to Blaze only if you accept pay-as-you-go billing.
- Enable Cloud Storage and publish `storage.rules`.
- Do not put Firebase Admin/service-account credentials in the Android app.

## 2. Firestore rules
Publish the included `firestore.rules` in the Firestore Rules tab.

## 3. Cloud Functions
From the project root, after installing/authenticating Firebase CLI:

```bash
firebase login
firebase use billi-billi-video
cd functions
npm install
cd ..
firebase deploy --only functions
```

The functions create notification documents and send FCM notifications for follows, likes, comments and chat messages.

## 4. Android build
The Android app already contains the Firebase configuration and Google Services setup. Build the release APK through the included GitHub Actions workflow or a Flutter environment.

## 5. Final real-device test
Test with two separate accounts/devices:
- follow -> notification
- like -> notification
- comment -> notification
- chat message -> notification
- photo/video upload -> Storage + online feed
- notification read / mark all read

## Important
The source package is deployment-ready, but Firebase Console billing activation, Storage enablement, Functions deployment, and physical-device testing require access to the user's Firebase/Android environment and cannot be honestly marked complete from this offline build environment.
