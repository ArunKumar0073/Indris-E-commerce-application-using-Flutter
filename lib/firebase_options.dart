// File generated from google-services.json — do not edit manually.
// Project: indris-app (276592305586)

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCn3dpAFcIh6qibo2InQbAmghnPBM1cP20',
    appId: '1:276592305586:android:63c1b1c3bd7864d4b8f0ab',
    messagingSenderId: '276592305586',
    projectId: 'indris-app',
    storageBucket: 'indris-app.firebasestorage.app',
  );

  // iOS — add a GoogleService-Info.plist and update these values
  // if you ever target iOS. For Android-only development this is unused.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCn3dpAFcIh6qibo2InQbAmghnPBM1cP20',
    appId: '1:276592305586:ios:63c1b1c3bd7864d4b8f0ab',
    messagingSenderId: '276592305586',
    projectId: 'indris-app',
    storageBucket: 'indris-app.firebasestorage.app',
    iosBundleId: 'com.example.application1',
  );

  // Web — register a web app in Firebase Console to get a real appId.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCn3dpAFcIh6qibo2InQbAmghnPBM1cP20',
    appId: '1:276592305586:web:63c1b1c3bd7864d4b8f0ab',
    messagingSenderId: '276592305586',
    projectId: 'indris-app',
    storageBucket: 'indris-app.firebasestorage.app',
    authDomain: 'indris-app.firebaseapp.com',
  );
}
