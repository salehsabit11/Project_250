import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// Teacher registration code stored in Firestore
  static Future<String> getTeacherCode() async {
    final doc =
        await _firestore.collection('settings').doc('app').get();

    if (!doc.exists) {
      throw Exception("Teacher code not found.");
    }

    return doc['teacherCode'];
  }

  /// Register User
  static Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    required String department,
    String? studentId,
    String? teacherId,
    String? semester,
    String? designation,
  }) async {
    // Create Firebase Authentication account
    final credential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;

    // Send verification email
    await user.sendEmailVerification();

    final userModel = UserModel(
      uid: user.uid,
      fullName: fullName,
      email: email,
      role: role,
      department: department,
      studentId: studentId,
      teacherId: teacherId,
      semester: semester,
      designation: designation,
      createdAt: DateTime.now(),
    );

    // Save user in Firestore
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap());

    return userModel;
  }

  /// Login
  static Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Logout
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// Forgot Password
  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Current Firebase User
  static User? get currentUser => _auth.currentUser;

  /// Check Email Verification
  static bool get isEmailVerified =>
      _auth.currentUser?.emailVerified ?? false;

  /// Get Current User Data
  static Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc =
        await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!);
  }

  /// Reload Firebase User
  static Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
}