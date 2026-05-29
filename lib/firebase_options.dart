// File generated from Firebase project configuration.
// Project: frd-fashion-store-app

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase is not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCWcBIhzjhRFFSLJbLyH_SpaMwkPKzqyz8',
    appId: '1:8535177474:web:81aae707b4d43e6bac6a1b',
    messagingSenderId: '8535177474',
    projectId: 'frd-fashion-store-app',
    authDomain: 'frd-fashion-store-app.firebaseapp.com',
    storageBucket: 'frd-fashion-store-app.firebasestorage.app',
    measurementId: 'G-5VB9P6DLNY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBoAT5lVjkxxWUZXO-B4J5mHQBgsXHIRiU',
    appId: '1:8535177474:android:646e631a21e03629ac6a1b',
    messagingSenderId: '8535177474',
    projectId: 'frd-fashion-store-app',
    storageBucket: 'frd-fashion-store-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDUs4ozqIODxE0yoa8WoeKNMbil2UIx0M8',
    appId: '1:8535177474:ios:cf163c3ab957cba8ac6a1b',
    messagingSenderId: '8535177474',
    projectId: 'frd-fashion-store-app',
    storageBucket: 'frd-fashion-store-app.firebasestorage.app',
    iosBundleId: 'com.example.frdFashionStoreApp',
  );
}
