// lib/firebase_options.dart
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
    apiKey: 'AIzaSyBeFIHf9mejPrLgCjDQey5xkkwO7XkGT80',
    appId: '1:618883180772:web:908d3cca69db759aeda4f1',
    messagingSenderId: '618883180772',
    projectId: 'rakt-setu-1445f',
    authDomain: 'rakt-setu-1445f.firebaseapp.com',
    storageBucket: 'rakt-setu-1445f.firebasestorage.app',
    measurementId: 'G-KWNTSHP72B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmxxawI3vcelBhUXIq-Y8TcAExo_GwL84',
    appId: '1:618883180772:android:cb1e2987ed743d53eda4f1',
    messagingSenderId: '618883180772',
    projectId: 'rakt-setu-1445f',
    storageBucket: 'rakt-setu-1445f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD1r6_GQ1txniDMBDINdhoHhhohgvBsjNQ',
    appId: '1:618883180772:ios:da1c9d1bd423b5dbeda4f1',
    messagingSenderId: '618883180772',
    projectId: 'rakt-setu-1445f',
    storageBucket: 'rakt-setu-1445f.firebasestorage.app',
    iosBundleId: 'com.raktsetu.raktsetu',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:1234567890:ios:1234567890abcdef',
    messagingSenderId: '1234567890',
    projectId: 'dummy-project',
    storageBucket: 'dummy-project.appspot.com',
    iosBundleId: 'com.example.raktsetu',
  );
}