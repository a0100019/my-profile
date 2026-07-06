import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBEmVwtGiCPjyfYqbJuG7husJ5BWK2U0Tw',
    appId: '1:384775334484:web:b5b26a281339dd4fa91bc1',
    messagingSenderId: '384775334484',
    projectId: 'my-profile-5209e',
    authDomain: 'my-profile-5209e.firebaseapp.com',
    storageBucket: 'my-profile-5209e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBEmVwtGiCPjyfYqbJuG7husJ5BWK2U0Tw',
    appId: '1:384775334484:web:b5b26a281339dd4fa91bc1',
    messagingSenderId: '384775334484',
    projectId: 'my-profile-5209e',
    storageBucket: 'my-profile-5209e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBEmVwtGiCPjyfYqbJuG7husJ5BWK2U0Tw',
    appId: '1:384775334484:web:b5b26a281339dd4fa91bc1',
    messagingSenderId: '384775334484',
    projectId: 'my-profile-5209e',
    storageBucket: 'my-profile-5209e.firebasestorage.app',
    iosBundleId: 'kr.mybio.mybio',
  );
}
