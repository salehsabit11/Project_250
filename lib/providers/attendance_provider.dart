import 'package:flutter/material.dart';

import '../models/attendance_session_model.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  bool _isLoading = false;

  AttendanceSessionModel? _currentSession;

  bool get isLoading => _isLoading;

  AttendanceSessionModel? get currentSession =>
      _currentSession;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// ==========================================================
  /// Start a NEW Class Session
  /// ==========================================================
  Future<String?> startAttendance({
    required String courseId,
    required String courseName,
    required String courseCode,
  }) async {
    try {
      _setLoading(true);

      _currentSession =
          await AttendanceService.startAttendance(
        courseId: courseId,
        courseName: courseName,
        courseCode: courseCode,
      );

      notifyListeners();

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// ==========================================================
  /// Regenerate QR
  ///
  /// IMPORTANT:
  /// This does NOT create a new class.
  /// It only creates a new QR token for
  /// the current class session.
  /// ==========================================================
  Future<String?> regenerateQr() async {
    if (_currentSession == null) {
      return "No active attendance session.";
    }

    try {
      _currentSession =
          await AttendanceService.regenerateQr(
        _currentSession!.id,
      );

      notifyListeners();

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// ==========================================================
  /// End Current Class
  /// ==========================================================
  Future<String?> stopAttendance() async {
    if (_currentSession == null) {
      return null;
    }

    try {
      await AttendanceService.stopAttendance(
        _currentSession!.id,
      );

      _currentSession = null;

      notifyListeners();

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// ==========================================================
  /// Load Existing Session Using Session ID
  /// ==========================================================
  Future<void> loadSession(
    String sessionId,
  ) async {
    try {
      _currentSession =
          await AttendanceService.getSession(
        sessionId,
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        "Error loading attendance session: $e",
      );

      _currentSession = null;

      notifyListeners();
    }
  }

  /// ==========================================================
  /// Load Session Using QR Token
  ///
  /// Student scanner uses this method.
  ///
  /// The QR contains qrToken, NOT sessionId.
  /// ==========================================================
  Future<void> loadSessionByQrToken(
    String qrToken,
  ) async {
    try {
      _currentSession =
          await AttendanceService.getSessionByQrToken(
        qrToken,
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        "Error loading QR session: $e",
      );

      _currentSession = null;

      notifyListeners();
    }
  }

  /// ==========================================================
  /// Clear Current Session
  /// ==========================================================
  void clearSession() {
    _currentSession = null;

    notifyListeners();
  }
}