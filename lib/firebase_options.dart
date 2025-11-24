import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyD8kj9aOB6ZE7_l3p8klfzG02KKFibE_bQ",
    authDomain: "plant-care-reminder-fa9bb.firebaseapp.com",
    projectId: "plant-care-reminder-fa9bb",
    storageBucket: "plant-care-reminder-fa9bb.firebasestorage.app",
    messagingSenderId: "477078190874",
    appId: "1:477078190874:web:9897f511357165d8574aa3",
  );
}