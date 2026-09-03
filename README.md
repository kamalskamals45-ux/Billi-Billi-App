# Billi Billi

## v16 – Online creator identity + Follow on posts
- Online posts now show the real Firestore profile name/bio when available.
- Online posts show Follow/Following for other users.
- Existing local and Firebase features remain included.
 — International Security Final

This is the final source package prepared from the Billi Billi International Security v9 FIXED project.

## Included
- Multi-language UI structure with 20+ language options.
- Arabic/Urdu RTL support.
- Country/region selection with locale and currency metadata.
- Privacy and security settings.
- Biometric app lock with lifecycle re-locking.
- Secure device storage for sensitive local security state.
- Local data deletion, including app preferences and stored media.
- Android cleartext HTTP disabled in the generated Android configuration.
- Release Dart obfuscation and split debug info in the GitHub Actions workflow.

## Important production security note
No client-only Flutter app can guarantee that data can never be stolen. Before public launch, the backend must enforce HTTPS/TLS, authentication, authorization, secure database rules, rate limiting, logging/monitoring, secret management, and least-privilege access. Never put server secrets or private API keys in the mobile app.

## Build
The included GitHub Actions workflow can generate a release APK. The local environment used to prepare this source package does not include the Flutter SDK, so a local Flutter compile was not performed here.

## New in 1.0.5+7
- Follow / Unfollow creator interface with local persistence.
- Find People screen.
- Chat list and one-to-one chat UI foundation.
- Existing international language/security features are retained.

Note: Follow and Chat are currently a local app foundation. Real multi-user online synchronization requires connecting a secure backend with authentication, authorization, database rules and HTTPS.

## New in 1.0.6+8 — Online Backend Foundation
- Added Firebase Core, Authentication, Firestore, Storage and Cloud Messaging dependencies.
- Added a separate Firebase bootstrap service so the existing UI is not rewritten or removed.
- Added an online social service for profiles, Follow/Unfollow, Followers and real-time one-to-one chat.
- Added starter Firestore and Storage security rules using authenticated-user checks.
- No Firebase project credentials, admin keys, or secrets are included in the app source.

### Firebase connection status in 1.0.7+9
- Connected to Firebase project `billi-billi-video` for Android package `com.billibilli.video`.
- Added `lib/firebase_options.dart` using the downloaded Android Firebase configuration.
- Added `android/app/google-services.json` for Android builds.
- GitHub Actions configures the Google Services Gradle plugin (4.5.0) and uses the included Firebase config in the generated Android project.
- The build workflow uses Flutter 3.47.0, matching the current stable Flutter release line and the current Firebase plugin toolchain.
- Firebase initialization is fail-safe: if a Firebase product is not enabled yet, the existing local Billi Billi experience still opens.

### Important
The Firebase project is connected at the app-configuration level, but **online social features are not considered fully live until Firebase Authentication (Anonymous or a real sign-in method), Firestore, and Storage are enabled and the supplied security rules are deployed**. No admin credentials are included. The existing local features remain intact.


### Online social connection (v1.1)
- Firebase Anonymous Authentication is used as the initial online identity so the app can connect without requiring a new login screen.
- The app creates/updates the signed-in user's Firestore profile.
- Find People now reads real user profiles from Firestore.
- Follow/Unfollow writes to the secured `following` and `followers` subcollections.
- Chat messages are read from and written to secured Firestore chat documents.
- If Firebase is temporarily unavailable, the existing local fallback remains available where applicable.
- This does not yet provide email/password account linking, media uploads, push notifications, or Cloud Storage; those are separate stages.


## v4 security hardening
- Chat membership is immutable after chat creation.
- Chat deletion is blocked.
- Chat message update/delete is blocked.
- Message sender/receiver and text-length checks are enforced by Firestore rules.
- Follow/follower writes are limited to the authenticated user identity.


## v1.2.0 account authentication
- Firebase Email/Password sign-up and login UI added.
- If the app is currently using an anonymous Firebase user, creating an account links the email/password credential to that existing user when Firebase allows it, preserving the same UID.
- Logout is now wired to Firebase Auth.
- Anonymous startup remains available as a fallback for the existing app experience.
- The Firebase Console must have Email/Password enabled (already enabled for the configured project during setup).


## v1.3.0 account improvements
- Added password-reset email from the Login screen.
- New email/password accounts request email verification.
- Added explicit sign-out state so restarting the app does not silently create a new anonymous account after the user logs out.
- Existing anonymous-to-email account linking remains preserved.


## v1.4.0 account improvements
- Added email verification status, resend verification, and refresh verification state.
- Added display-name editing with Firebase Authentication + Firestore profile update.
- Existing Firebase, Follow, Followers, Chat, internationalization and security features are preserved.


## v1.3.0+14
- Added real-time Firestore Followers and Following lists.
- Profile now shows online follower/following counts and opens the corresponding lists.
- Existing v1-v7 features remain included.


## v1.5.0 online media
- Added Firebase Storage upload for photos/videos under each user's own Storage path.
- Added Firestore `posts` metadata and authenticated online feed.
- Local posting remains available if Storage is unavailable; the app reports that online upload requires Storage.
- Firebase Storage must be enabled on a billing plan that supports Cloud Storage before online media upload can succeed.


## v1.6.0 Online engagement
- Added Firestore-backed post likes, comments, and in-app notifications.
- Local likes/comments remain as a fallback when online services are unavailable.
- Firebase Storage remains dependent on the project billing/storage availability.


## v1.7.0 — Push notification foundation
- Registers the signed-in Android device FCM token in Firestore under the user's `deviceTokens` collection.
- Handles FCM token refresh.
- Requests notification permission when push setup is initialized.
- Firestore rules restrict device-token access to the owning user.
- Actual notification delivery still requires a trusted server/Cloud Functions/FCM sender; the client never contains server credentials.

## v12 trusted notification backend
- Added `functions/` using Firebase Cloud Functions 2nd gen and Node.js 22.
- Trusted triggers create in-app notifications and send FCM push notifications for follow, like, comment, and chat message events.
- Invalid/unregistered FCM tokens are removed by the trusted backend.
- The app never receives Firebase Admin credentials.
- `firebase.json` and `.firebaserc` target project `billi-billi-video`.
- Deploying Cloud Functions requires the Firebase project to use the Blaze plan.
- Storage still requires Blaze and must be enabled in Firebase Console before online media uploads can be tested.


## v13 notification reliability and privacy hardening
- Fixed the notification UI to use the trusted backend's `title`, `body`, `actorName`, and `read` fields.
- Added per-notification and mark-all-as-read actions.
- Firestore rules now allow the owner to change only the `read` flag; notification creation remains backend-only.
- Existing Firebase, Storage, FCM, Follow, Followers, Chat, internationalization, security, and local fallback features are preserved.

## v15 feature update
- Search now has three tabs: local Posts, Online posts, and People.
- Online search filters published Firestore posts by caption/media type.
- People search filters online profiles by display name or bio and keeps Follow/Chat actions.
- Existing local, Firebase, security, chat, follow, notification and upload features are preserved.


## v17 feature update
- Home notification bell now shows a live unread-count badge from Firestore notifications.
- Existing notification page, mark-read, and mark-all-read behavior is preserved.
