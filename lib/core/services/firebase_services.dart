
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:seafarer_bio_data/firebase_options.dart';

class FirebaseServices {
  static final FirebaseServices _instance = FirebaseServices._internal();

  factory FirebaseServices() {
    return _instance;
  }
  FirebaseServices._internal();

  FirebaseFirestore? _firestore;

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get fireStore {
    if (_firestore == null) {
      throw Exception(
          "Firebase has not been initialized. Call initializeFirebase() first.");
    }
    return _firestore!;
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    _firestore = FirebaseFirestore.instance;
  }
}
