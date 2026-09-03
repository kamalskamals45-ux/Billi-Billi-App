import 'package:firebase_core/firebase_core.dart';

/// Firebase bootstrap kept separate from the UI so the existing Billi Billi
/// screens remain unchanged until the Firebase project is configured.
class FirebaseBackend {
  FirebaseBackend._();

  static bool get isReady => Firebase.apps.isNotEmpty;

  static Future<void> initialize({FirebaseOptions? options}) async {
    if (Firebase.apps.isNotEmpty) return;
    if (options == null) {
      throw StateError(
        'Firebase is not configured yet. Add the generated firebase_options.dart '
        'for the Billi Billi Firebase project before calling initialize().',
      );
    }
    await Firebase.initializeApp(options: options);
  }
}
