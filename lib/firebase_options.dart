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
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAljjXBDqWkwU4FVNewQwO90WSj3pc2RGc',
    appId: '1:174052895949:android:0b177399b2460c84088d84',
    messagingSenderId: '174052895949',
    projectId: 'comment-corp',
    storageBucket: 'comment-corp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBHrCDLJjJ-QjapvDZbszPeNnCc2lbjwW8',
    appId: '1:174052895949:ios:f3f004158734d663088d84',
    messagingSenderId: '174052895949',
    projectId: 'comment-corp',
    storageBucket: 'comment-corp.firebasestorage.app',
    iosBundleId: 'com.commentcorp.commentCorp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBHrCDLJjJ-QjapvDZbszPeNnCc2lbjwW8',
    appId: '1:174052895949:ios:f3f004158734d663088d84',
    messagingSenderId: '174052895949',
    projectId: 'comment-corp',
    storageBucket: 'comment-corp.firebasestorage.app',
    iosBundleId: 'com.commentcorp.commentCorp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBByBEviMNjj7FSxQ-b7UXildObn0UDXdE',
    appId: '1:174052895949:web:e067791dd79fea27088d84',
    messagingSenderId: '174052895949',
    projectId: 'comment-corp',
    storageBucket: 'comment-corp.firebasestorage.app',
    authDomain: 'comment-corp.firebaseapp.com',
  );
}
