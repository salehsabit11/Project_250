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

  /// ==========================================================
  /// Student - Mark Attendance
  /// ==========================================================
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

  /// ==========================================================
  /// Teacher - All Attendance Records
  /// ==========================================================
  Stream<List<AttendanceRecordModel>> getCourseAttendance(
    String courseId,
  ) {
    return AttendanceRecordService.getCourseAttendance(
      courseId,
    );
  }

  /// ==========================================================
  /// Teacher - Student Attendance Summary
  /// ==========================================================
  Stream<List<StudentAttendanceSummary>>
      getCourseAttendanceSummary(
    String courseId,
  ) {
    return AttendanceRecordService.getCourseAttendanceSummary(
      courseId,
    );
  }

  /// ==========================================================
  /// Teacher - Course Statistics
  /// ==========================================================
  Stream<List<CourseStatisticsModel>>
      getCourseStatistics(
    String courseId,
  ) {
    return AttendanceRecordService.getCourseStatistics(
      courseId,
    );
  }

  /// ==========================================================
  /// Teacher - All Class Sessions
  /// ==========================================================
  Stream<List<ClassSessionModel>>
      getCourseClassSessions(
    String courseId,
  ) {
    return AttendanceRecordService.getCourseClassSessions(
      courseId,
    );
  }

  /// ==========================================================
  /// Teacher - Students Present In One Session
  /// ==========================================================
  Stream<List<AttendanceRecordModel>>
      getSessionAttendance(
    String sessionId,
  ) {
    return AttendanceRecordService.getSessionAttendance(
      sessionId,
    );
  }

  /// ==========================================================
  /// Teacher - Single Student Attendance History
  /// ==========================================================
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

  /// ==========================================================
  /// Student - Attendance Summary For One Course
  /// ==========================================================
  Stream<StudentCourseSummaryModel>
      getStudentCourseSummary({
    required String courseId,
  }) {
    return AttendanceRecordService.getStudentCourseSummary(
      courseId: courseId,
    );
  }

  /// ==========================================================
  /// Student - Complete Attendance History
  /// ==========================================================
  Stream<List<AttendanceRecordModel>>
      getStudentAttendance() {
    return AttendanceRecordService.getStudentAttendance();
  }

  Stream<List<AttendanceRecordModel>>? getStudentCourseAttendanceForCurrentUser(String id) {
    return null;
  }
}