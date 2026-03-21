import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<bool> registerGeneralUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return false;
      }

      await _firestore.collection('users').doc(uid).set({
        'id': uid,
        'name': name,
        'email': email,
        'role': 'general_user',
        'created_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (error) {
      print('AUTH ERROR: $error');
      return false;
    }
  }

  Future<bool> registerProfessionalUser({
    required String name,
    required String email,
    required String password,
    required String licenseNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return false;
      }

      await _firestore.collection('users').doc(uid).set({
        'id': uid,
        'name': name,
        'email': email,
        'role': 'psychiatrist',
        'license_number': licenseNumber,
        'created_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (error) {
      print('AUTH ERROR: $error');
      return false;
    }
  }

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return null;
      }
      final snapshot = await _firestore.collection('users').doc(uid).get();
      final data = snapshot.data();
      return data?['role'] as String?;
    } catch (error) {
      print('AUTH ERROR: $error');
      return null;
    }
  }
}
