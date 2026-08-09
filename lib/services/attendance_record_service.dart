import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/attendance_record_model.dart';
import '../models/attendance_session_model.dart';
import '../models/student_attendance_summary.dart';

import '../models/course_statistics_model.dart';
import '../models/class_session_model.dart';

import '../models/student_course_summary_model.dart';

class AttendanceRecordService {
  AttendanceRecordService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ===========================================================
  /// Mark Attendance
  /// ===========================================================
static Future<void> markAttendance({
  required AttendanceSessionModel session,
}) async {
  final firebaseUser = _auth.currentUser;

  if (firebaseUser == null) {
    throw Exception("User not logged in.");
  }

  // ==========================================================
  // Check whether the class session is still active
  // ==========================================================
  if (!session.isActive) {
    throw Exception(
      "This attendance class has already ended.",
    );
  }

  // ==========================================================
  // Check session expiration
  // ==========================================================
  if (DateTime.now().isAfter(session.endTime)) {
    throw Exception(
      "This QR code has expired.",
    );
  }

  // ==========================================================
  // Get student information
  // ==========================================================
  final studentDoc = await _firestore
      .collection("users")
      .doc(firebaseUser.uid)
      .get();

  if (!studentDoc.exists) {
    throw Exception("Student not found.");
  }

  final student = studentDoc.data()!;

  final regNo = student["studentId"] ?? "";

  if (regNo.toString().isEmpty) {
    throw Exception(
      "Student registration number not found.",
    );
  }

  // ==========================================================
  // Check course enrollment
  // ==========================================================
  final enrollment = await _firestore
      .collection("course_enrollments")
      .where(
        "courseId",
        isEqualTo: session.courseId,
      )
      .where(
        "studentId",
        isEqualTo: firebaseUser.uid,
      )
      .limit(1)
      .get();

  if (enrollment.docs.isEmpty) {
    throw Exception(
      "You are not enrolled in this course.",
    );
  }

  // ==========================================================
  // PREVENT DUPLICATE ATTENDANCE
  //
  // Same student + same session = only ONE attendance
  // ==========================================================
  final duplicate = await _firestore
      .collection("attendance_records")
      .where(
        "sessionId",
        isEqualTo: session.id,
      )
      .where(
        "studentUid",
        isEqualTo: firebaseUser.uid,
      )
      .limit(1)
      .get();

  if (duplicate.docs.isNotEmpty) {
    throw Exception(
      "Attendance already marked for this class.",
    );
  }

  // ==========================================================
  // Create attendance record
  // ==========================================================
  final doc = _firestore
      .collection("attendance_records")
      .doc();

  final record = AttendanceRecordModel(
    id: doc.id,

    // Same session for all QR regenerations
    sessionId: session.id,

    // Actual class number
    classNumber: session.classNumber,

    courseId: session.courseId,
    courseName: session.courseName,
    courseCode: session.courseCode,

    teacherUid: session.teacherUid,

    studentUid: firebaseUser.uid,
    studentId: regNo.toString(),

    studentName:
        student["fullName"] ?? "",

    studentEmail:
        student["email"] ?? "",

    attendanceTime: DateTime.now(),
  );

  await doc.set(record.toMap());
}

  /// ===========================================================
  /// Teacher - Raw Attendance Records
  /// ===========================================================
  static Stream<List<AttendanceRecordModel>> getCourseAttendance(
    String courseId,
  ) {
    return _firestore
        .collection("attendance_records")
        .where("courseId", isEqualTo: courseId)
        .snapshots()
        .map((snapshot) {
          final records = snapshot.docs
              .map((doc) => AttendanceRecordModel.fromMap(doc.data()))
              .toList();

          records.sort((a, b) => a.studentId.compareTo(b.studentId));

          return records;
        });
  }

  /// ===========================================================
  /// Teacher - Attendance Summary (One Card Per Student)
  /// ===========================================================
  static Stream<List<StudentAttendanceSummary>> getCourseAttendanceSummary(
    String courseId,
  ) {
    return _firestore
        .collection("attendance_records")
        .where("courseId", isEqualTo: courseId)
        .snapshots()
        .map((snapshot) {
          final Map<String, List<AttendanceRecordModel>> groupedStudents = {};

          // Group records by student UID
          for (final doc in snapshot.docs) {
            final record = AttendanceRecordModel.fromMap(doc.data());

            groupedStudents.putIfAbsent(record.studentUid, () => []);

            groupedStudents[record.studentUid]!.add(record);
          }

          final List<StudentAttendanceSummary> summaries = [];

          groupedStudents.forEach((uid, records) {
            // Latest attendance first
            records.sort(
              (a, b) => b.attendanceTime.compareTo(a.attendanceTime),
            );

            final latest = records.first;

            summaries.add(
              StudentAttendanceSummary(
                studentUid: latest.studentUid,
                studentId: latest.studentId,
                studentName: latest.studentName,
                studentEmail: latest.studentEmail,
                totalPresent: records.length,
                lastAttendance: latest.attendanceTime,
              ),
            );
          });

          // Sort by registration number
          summaries.sort((a, b) => a.studentId.compareTo(b.studentId));

          return summaries;
        });
  }

  /// ===========================================================
  /// Student Attendance History
  /// ===========================================================
  static Stream<List<AttendanceRecordModel>> getStudentAttendance() {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection("attendance_records")
        .where("studentUid", isEqualTo: firebaseUser.uid)
        .snapshots()
        .map((snapshot) {
          final records = snapshot.docs
              .map((doc) => AttendanceRecordModel.fromMap(doc.data()))
              .toList();

          records.sort((a, b) => b.attendanceTime.compareTo(a.attendanceTime));

          return records;
        });
  }

  /// Teacher - Attendance history of one student in one course
  static Stream<List<AttendanceRecordModel>> getStudentCourseAttendance({
    required String courseId,
    required String studentUid,
  }) {
    return _firestore
        .collection("attendance_records")
        .where("courseId", isEqualTo: courseId)
        .where("studentUid", isEqualTo: studentUid)
        .snapshots()
        .map((snapshot) {
          final records = snapshot.docs
              .map((doc) => AttendanceRecordModel.fromMap(doc.data()))
              .toList();

          records.sort((a, b) => b.attendanceTime.compareTo(a.attendanceTime));

          return records;
        });
  }

  /// ===========================================================
  /// Teacher - Course Statistics (Present / Total / Percentage)
  /// ===========================================================
  static Stream<List<CourseStatisticsModel>> getCourseStatistics(
    String courseId,
  ) {
    return FirebaseFirestore.instance
        .collection("attendance_sessions")
        .where("courseId", isEqualTo: courseId)
        .snapshots()
        .asyncMap((sessionSnapshot) async {
          final totalClasses = sessionSnapshot.docs.length;

          final attendanceSnapshot = await FirebaseFirestore.instance
              .collection("attendance_records")
              .where("courseId", isEqualTo: courseId)
              .get();

          final Map<String, List<AttendanceRecordModel>> grouped = {};

          for (final doc in attendanceSnapshot.docs) {
            final record = AttendanceRecordModel.fromMap(doc.data());

            grouped.putIfAbsent(record.studentUid, () => []);

            grouped[record.studentUid]!.add(record);
          }

          final List<CourseStatisticsModel> statistics = [];

          grouped.forEach((uid, records) {
            final first = records.first;

            statistics.add(
              CourseStatisticsModel(
                studentUid: first.studentUid,
                studentId: first.studentId,
                studentName: first.studentName,
                studentEmail: first.studentEmail,
                totalPresent: records.length,
                totalClasses: totalClasses,
              ),
            );
          });

          statistics.sort((a, b) => a.studentId.compareTo(b.studentId));

          return statistics;
        });
  }

  /// ===========================================================
  /// Teacher - Get All Class Sessions
  /// ===========================================================
  static Stream<List<ClassSessionModel>> getCourseClassSessions(
    String courseId,
  ) {
    return _firestore
        .collection("attendance_sessions")
        .where("courseId", isEqualTo: courseId)
        .orderBy("classNumber")
        .snapshots()
        .asyncMap((sessionSnapshot) async {
          List<ClassSessionModel> classes = [];

          for (final sessionDoc in sessionSnapshot.docs) {
            final data = sessionDoc.data();

            final attendanceSnapshot = await _firestore
                .collection("attendance_records")
                .where("sessionId", isEqualTo: sessionDoc.id)
                .get();

            classes.add(
              ClassSessionModel(
                sessionId: sessionDoc.id,
                classNumber: data["classNumber"] ?? 1,
                classDate: (data["startTime"] as Timestamp).toDate(),
                totalPresent: attendanceSnapshot.docs.length,
              ),
            );
          }

          classes.sort((a, b) => a.classNumber.compareTo(b.classNumber));

          return classes;
        });
  }

  /// ===========================================================
  /// Teacher - Students Present In One Class Session
  /// ===========================================================
  static Stream<List<AttendanceRecordModel>> getSessionAttendance(
    String sessionId,
  ) {
    return _firestore
        .collection("attendance_records")
        .where("sessionId", isEqualTo: sessionId)
        .snapshots()
        .map((snapshot) {
          final records = snapshot.docs
              .map((doc) => AttendanceRecordModel.fromMap(doc.data()))
              .toList();

          // Sort by Registration Number
          records.sort((a, b) => a.studentId.compareTo(b.studentId));

          return records;
        });
  }

  /// ===========================================================
  /// Student - Course Attendance Summary
  /// ===========================================================
  static Stream<StudentCourseSummaryModel> getStudentCourseSummary({
    required String courseId,
  }) {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      return Stream.value(
        const StudentCourseSummaryModel(totalClasses: 0, totalPresent: 0, records: []),
      );
    }

    return _firestore
        .collection("attendance_sessions")
        .where("courseId", isEqualTo: courseId)
        .snapshots()
        .asyncMap((sessionSnapshot) async {
          final totalClasses = sessionSnapshot.docs.length;

          final attendanceSnapshot = await _firestore
              .collection("attendance_records")
              .where("courseId", isEqualTo: courseId)
              .where("studentUid", isEqualTo: firebaseUser.uid)
              .get();

          final records = attendanceSnapshot.docs
              .map((doc) => AttendanceRecordModel.fromMap(doc.data()))
              .toList();

          records.sort((a, b) => b.attendanceTime.compareTo(a.attendanceTime));

          final totalPresent = records.length;

          return StudentCourseSummaryModel(
            totalClasses: totalClasses,
            totalPresent: totalPresent,
            records: records,
          );
        });
  }
}
