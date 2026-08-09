import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/attendance_session_model.dart';

class AttendanceService {
  AttendanceService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  /// ==========================================================
  /// Start a NEW Class Session
  /// ==========================================================
  static Future<AttendanceSessionModel> startAttendance({
    required String courseId,
    required String courseName,
    required String courseCode,
  }) async {
    final teacher = _auth.currentUser;

    if (teacher == null) {
      throw Exception("Teacher not logged in.");
    }

    // ----------------------------------------------------------
    // Find the last class number for this course
    // ----------------------------------------------------------
    final previousSessions = await _firestore
        .collection("attendance_sessions")
        .where("courseId", isEqualTo: courseId)
        .orderBy("classNumber", descending: true)
        .limit(1)
        .get();

    int nextClassNumber = 1;

    if (previousSessions.docs.isNotEmpty) {
      final data = previousSessions.docs.first.data();

      final lastClassNumber =
          data["classNumber"] ?? 0;

      nextClassNumber =
          (lastClassNumber as int) + 1;
    }

    // ----------------------------------------------------------
    // Create ONE session for this class
    // ----------------------------------------------------------
    final doc =
        _firestore.collection("attendance_sessions").doc();

    final now = DateTime.now();

    final qrToken = _generateQrToken();

    final session = AttendanceSessionModel(
      id: doc.id,
      courseId: courseId,
      courseName: courseName,
      courseCode: courseCode,
      teacherUid: teacher.uid,
      classNumber: nextClassNumber,
      startTime: now,

      // First QR expires after 10 seconds
      endTime: now.add(
        const Duration(seconds: 10),
      ),

      isActive: true,

      qrToken: qrToken,
    );

    await doc.set(
      session.toMap(),
    );

    return session;
  }

  /// ==========================================================
  /// Generate NEW QR for SAME Class Session
  /// ==========================================================
  static Future<AttendanceSessionModel>
      regenerateQr(
    String sessionId,
  ) async {
    final sessionRef = _firestore
        .collection("attendance_sessions")
        .doc(sessionId);

    final doc = await sessionRef.get();

    if (!doc.exists) {
      throw Exception(
        "Attendance session not found.",
      );
    }

    final data = doc.data()!;

    final isActive =
        data["isActive"] ?? false;

    if (isActive != true) {
      throw Exception(
        "Attendance session has already ended.",
      );
    }

    final newQrToken =
        _generateQrToken();

    final newEndTime =
        DateTime.now().add(
      const Duration(seconds: 10),
    );

    await sessionRef.update({
      "qrToken": newQrToken,
      "endTime":
          Timestamp.fromDate(newEndTime),
    });

    // Return updated session
    final updatedDoc =
        await sessionRef.get();

    return AttendanceSessionModel.fromMap(
      updatedDoc.data()!,
    );
  }

  /// ==========================================================
  /// Generate QR Token
  /// ==========================================================
  static String _generateQrToken() {
    final random = Random();

    return "${DateTime.now().millisecondsSinceEpoch}"
        "_${random.nextInt(999999)}";
  }

  /// ==========================================================
  /// Get One Attendance Session
  /// ==========================================================
  static Future<AttendanceSessionModel?>
      getSession(
    String sessionId,
  ) async {
    final doc = await _firestore
        .collection("attendance_sessions")
        .doc(sessionId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return AttendanceSessionModel.fromMap(
      doc.data()!,
    );
  }
  /// ==========================================================
/// Find Active Session Using QR Token
/// ==========================================================
static Future<AttendanceSessionModel?> getSessionByQrToken(
  String qrToken,
) async {
  final snapshot = await _firestore
      .collection("attendance_sessions")
      .where(
        "qrToken",
        isEqualTo: qrToken,
      )
      .where(
        "isActive",
        isEqualTo: true,
      )
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) {
    return null;
  }

  final session =
      AttendanceSessionModel.fromMap(
    snapshot.docs.first.data(),
  );

  // Check whether this QR has expired.
  if (DateTime.now().isAfter(session.endTime)) {
    return null;
  }

  return session;
}

  /// ==========================================================
  /// Stop / End Class Session
  /// ==========================================================
  static Future<void> stopAttendance(
    String sessionId,
  ) async {
    await _firestore
        .collection("attendance_sessions")
        .doc(sessionId)
        .update({
      "isActive": false,
    });
  }
}