import 'package:flutter/material.dart';

import '../models/attendance_record_model.dart';
import '../models/attendance_session_model.dart';
import '../models/class_session_model.dart';
import '../models/course_statistics_model.dart';
import '../models/student_attendance_summary.dart';
import '../models/student_course_summary_model.dart';

import '../services/attendance_record_service.dart';

class AttendanceRecordProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ==========================================================
  // STUDENT
  // MARK ATTENDANCE THROUGH QR
  // ==========================================================

  Future<String?> markAttendance({
    required AttendanceSessionModel session,
  }) async {
    try {
      _setLoading(true);

      await AttendanceRecordService.markAttendance(
        session: session,
      );

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // TEACHER
  // GET ALL STUDENTS ENROLLED IN COURSE
  // ==========================================================

  Stream<List<Map<String, dynamic>>> getCourseStudents(
    String courseId,
  ) {
    return AttendanceRecordService.getCourseStudents(
      courseId,
    );
  }

  // ==========================================================
  // TEACHER
  // FIND STUDENT BY UNIVERSITY ID
  // ==========================================================

  Future<Map<String, dynamic>?> findStudentById(
    String studentId,
  ) async {
    try {
      _setLoading(true);

      return await AttendanceRecordService.findStudentById(
        studentId,
      );
    } catch (e) {
      debugPrint(
        "Error finding student: $e",
      );

      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // TEACHER
  // ADD STUDENT TO COURSE
  // ==========================================================

  Future<String?> addStudentToCourse({
    required String courseId,
    required String courseName,
    required String courseCode,
    required String teacherUid,
    required String teacherCode,
    required String studentUid,
  }) async {
    try {
      _setLoading(true);

      await AttendanceRecordService.addStudentToCourse(
        courseId: courseId,
        courseName: courseName,
        courseCode: courseCode,
        teacherUid: teacherUid,
        teacherCode: teacherCode,
        studentUid: studentUid,
      );

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // TEACHER
  // MANUALLY MARK STUDENT PRESENT / ABSENT
  // ==========================================================

  Future<String?> markStudentAttendanceManually({
    required AttendanceSessionModel session,
    required String studentUid,
    required String status,
  }) async {
    try {
      _setLoading(true);

      await AttendanceRecordService.markStudentAttendanceManually(
        session: session,
        studentUid: studentUid,
        status: status,
      );

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // TEACHER
  // UPDATE PRESENT / ABSENT STATUS
  // ==========================================================

  Future<String?> updateAttendanceStatus({
    required String recordId,
    required String status,
  }) async {
    try {
      _setLoading(true);

      await AttendanceRecordService.updateAttendanceStatus(
        recordId: recordId,
        status: status,
      );

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // TEACHER
  // GET ATTENDANCE FOR ONE CLASS SESSION
  // ==========================================================

  Stream<List<AttendanceRecordModel>> getSessionAttendance(
    String sessionId,
  ) {
    return AttendanceRecordService.getSessionAttendance(
      sessionId,
    );
  }

  // ==========================================================
  // TEACHER
  // ALL ATTENDANCE RECORDS OF COURSE
  // ==========================================================

  Stream<List<AttendanceRecordModel>> getCourseAttendance(
    String courseId,
  ) {
    return AttendanceRecordService.getCourseAttendance(
      courseId,
    );
  }

  // ==========================================================
  // TEACHER
  // STUDENT ATTENDANCE SUMMARY
  // ==========================================================

  Stream<List<StudentAttendanceSummary>>
      getCourseAttendanceSummary(
    String courseId,
  ) {
    return AttendanceRecordService.getCourseAttendanceSummary(
      courseId,
    );
  }

  // ==========================================================
  // TEACHER
  // COURSE STATISTICS
  // ==========================================================

  Stream<List<CourseStatisticsModel>>
      getCourseStatistics(
    String courseId,
  ) {
    return AttendanceRecordService.getCourseStatistics(
      courseId,
    );
  }

  // ==========================================================
  // TEACHER
  // ALL CLASS SESSIONS
  // ==========================================================

  Stream<List<ClassSessionModel>>
      getCourseClassSessions(
    String courseId,
  ) {
    return AttendanceRecordService.getCourseClassSessions(
      courseId,
    );
  }

  // ==========================================================
  // TEACHER
  // ONE STUDENT ATTENDANCE HISTORY
  // ==========================================================

  Stream<List<AttendanceRecordModel>>
      getStudentCourseAttendance({
    required String courseId,
    required String studentUid,
  }) {
    return AttendanceRecordService.getStudentCourseAttendance(
      courseId: courseId,
      studentUid: studentUid,
    );
  }

  // ==========================================================
  // STUDENT
  // COURSE ATTENDANCE SUMMARY
  // ==========================================================

  Stream<StudentCourseSummaryModel>
      getStudentCourseSummary({
    required String courseId,
  }) {
    return AttendanceRecordService.getStudentCourseSummary(
      courseId: courseId,
    );
  }

  // ==========================================================
  // STUDENT
  // COMPLETE ATTENDANCE HISTORY
  // ==========================================================

  Stream<List<AttendanceRecordModel>>
      getStudentAttendance() {
    return AttendanceRecordService.getStudentAttendance();
  }
}