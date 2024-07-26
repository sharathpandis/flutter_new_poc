import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<UserCredential> signInWithUserId(String email, password) async {
    try {
      UserCredential userCredentials = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _fireStore.collection("Users").doc(userCredentials.user!.uid).set(
        {
          'uid': userCredentials.user!.uid,
          'email': email,
        },
      );
      return userCredentials;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  User getCurrrentUser() {
    try {
      User user = _auth.currentUser!;
      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserCredential> signUpWithUserId(String email, password) async {
    try {
      UserCredential userCredentials = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      _fireStore.collection("Users").doc(userCredentials.user!.uid).set(
        {
          'uid': userCredentials.user!.uid,
          'email': email,
        },
      );
      return userCredentials;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
