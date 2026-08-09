import 'package:attendence_app1/sevices/auth_service.dart' hide AuthService;
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Register a new user
  Future<String?> register({
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
    try {
      _setLoading(true);

      await AuthService.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        department: department,
        studentId: studentId,
        teacherId: teacherId,
        semester: semester,
        designation: designation,
      );

      _currentUser = await AuthService.getCurrentUserData();

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);

      await AuthService.login(
        email: email,
        password: password,
      );

      _currentUser = await AuthService.getCurrentUserData();

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Logout
  Future<void> logout() async {
    await AuthService.logout();
    _currentUser = null;
    notifyListeners();
  }

  /// Forgot Password
  Future<String?> resetPassword(String email) async {
    try {
      _setLoading(true);

      await AuthService.resetPassword(email);

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Load current user from Firestore
  Future<void> loadCurrentUser() async {
    _currentUser = await AuthService.getCurrentUserData();
    notifyListeners();
  }
}