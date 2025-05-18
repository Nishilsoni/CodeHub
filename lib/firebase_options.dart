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
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDBuXEFHUbeeQAz1zZCHPwXJ4I3wzhyA78',
    appId: '1:411581117758:web:b35cb63a8eb729db5a286f',
    messagingSenderId: '411581117758',
    projectId: 'productive-hub-c1381',
    authDomain: 'productive-hub-c1381.firebaseapp.com',
    storageBucket: 'productive-hub-c1381.firebasestorage.app',
    measurementId: 'G-73ME6HJ770',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDBuXEFHUbeeQAz1zZCHPwXJ4I3wzhyA78',
    appId: '1:411581117758:android:b35cb63a8eb729db5a286f',
    messagingSenderId: '411581117758',
    projectId: 'productive-hub-c1381',
    storageBucket: 'productive-hub-c1381.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBuXEFHUbeeQAz1zZCHPwXJ4I3wzhyA78',
    appId: '1:411581117758:ios:b35cb63a8eb729db5a286f',
    messagingSenderId: '411581117758',
    projectId: 'productive-hub-c1381',
    storageBucket: 'productive-hub-c1381.firebasestorage.app',
    iosClientId: '411581117758-ios-client-id',
    iosBundleId: 'com.example.codehub',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDBuXEFHUbeeQAz1zZCHPwXJ4I3wzhyA78',
    appId: '1:411581117758:macos:b35cb63a8eb729db5a286f',
    messagingSenderId: '411581117758',
    projectId: 'productive-hub-c1381',
    storageBucket: 'productive-hub-c1381.firebasestorage.app',
    iosClientId: '411581117758-macos-client-id',
    iosBundleId: 'com.example.codehub',
  );
} 