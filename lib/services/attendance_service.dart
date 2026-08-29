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

  // ==========================================================
  // START A NEW CLASS SESSION
  // ==========================================================
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
        .where(
          "courseId",
          isEqualTo: courseId,
        )
        .orderBy(
          "classNumber",
          descending: true,
        )
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
    // Create a new attendance session
    // ----------------------------------------------------------
    final doc = _firestore
        .collection("attendance_sessions")
        .doc();

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

    // ----------------------------------------------------------
    // Save session to Firestore
    // ----------------------------------------------------------
    await doc.set(
      session.toMap(),
    );

    return session;
  }

  // ==========================================================
  // GENERATE NEW QR FOR SAME CLASS SESSION
  // ==========================================================
  static Future<AttendanceSessionModel> regenerateQr(
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

    // Generate a new QR token
    final newQrToken = _generateQrToken();

    // New QR expires after 10 seconds
    final newEndTime = DateTime.now().add(
      const Duration(seconds: 10),
    );

    await sessionRef.update({
      "qrToken": newQrToken,
      "endTime": Timestamp.fromDate(
        newEndTime,
      ),
    });

    // Get updated session
    final updatedDoc =
        await sessionRef.get();

    return AttendanceSessionModel.fromMap(
      updatedDoc.data()!,
    );
  }

  // ==========================================================
  // GENERATE QR TOKEN
  // ==========================================================
  static String _generateQrToken() {
    final random = Random();

    return "${DateTime.now().millisecondsSinceEpoch}"
        "_${random.nextInt(999999)}";
  }

  // ==========================================================
  // GET ONE ATTENDANCE SESSION
  // ==========================================================
  static Future<AttendanceSessionModel?> getSession(
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

  // ==========================================================
  // GET ALL ATTENDANCE SESSIONS
  //
  // Newest session will appear first.
  // Sorted using startTime.
  // ==========================================================
  static Stream<List<AttendanceSessionModel>>
      getAllSessions() {
    return _firestore
        .collection("attendance_sessions")
        .orderBy(
          "startTime",
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs.map(
              (doc) {
                return AttendanceSessionModel.fromMap(
                  doc.data(),
                );
              },
            ).toList();
          },
        );
  }

  // ==========================================================
  // GET SESSIONS FOR ONE COURSE
  //
  // Newest class of that course will appear first.
  // ==========================================================
  static Stream<List<AttendanceSessionModel>>
      getCourseSessions(
    String courseId,
  ) {
    return _firestore
        .collection("attendance_sessions")
        .where(
          "courseId",
          isEqualTo: courseId,
        )
        .orderBy(
          "startTime",
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs.map(
              (doc) {
                return AttendanceSessionModel.fromMap(
                  doc.data(),
                );
              },
            ).toList();
          },
        );
  }

  // ==========================================================
  // FIND ACTIVE SESSION USING QR TOKEN
  // ==========================================================
  static Future<AttendanceSessionModel?>
      getSessionByQrToken(
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

    // ----------------------------------------------------------
    // Check whether QR has expired
    // ----------------------------------------------------------
    if (DateTime.now().isAfter(
      session.endTime,
    )) {
      return null;
    }

    return session;
  }

  // ==========================================================
  // STOP / END CLASS SESSION
  // ==========================================================
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