// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_API_KEY',
      defaultValue: 'YOUR_FIREBASE_API_KEY',
    ),
    appId: '1:374311262430:android:f6bf417bb07e28e3444a4f',
    messagingSenderId: '374311262430',
    projectId: 'talk2metro-4f3e0',
    storageBucket: 'talk2metro-4f3e0.firebasestorage.app',
  );
}
