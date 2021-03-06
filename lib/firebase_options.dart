// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDFElnuC39jJNNgG728LXCasYPFFBO07Y0',
    appId: '1:80829205010:android:34fe0d19655e5ee8eb66cb',
    messagingSenderId: '80829205010',
    projectId: 'note-8cfa1',
    storageBucket: 'note-8cfa1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDgSih61sQIRKm_YeV7wm8D3HnjqeDaR7w',
    appId: '1:80829205010:ios:2c06015ceacc441eeb66cb',
    messagingSenderId: '80829205010',
    projectId: 'note-8cfa1',
    storageBucket: 'note-8cfa1.appspot.com',
    iosClientId: '80829205010-pjtd6bth5duv7gqbi9qe1c6he8jo55gi.apps.googleusercontent.com',
    iosBundleId: 'info.aboidrees.notes',
  );
}
