// Run this command from the project root:
//
// flutterfire configure
//
// FlutterFire CLI will replace this placeholder with your Firebase config.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase options have not been generated. '
      'Run "flutterfire configure" to generate firebase_options.dart.',
    );
  }
}
