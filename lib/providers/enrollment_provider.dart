import 'package:flutter/material.dart';

import '../models/enrollment_model.dart';
import '../services/enrollment_service.dart';

class EnrollmentProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Join Course
  Future<String?> joinCourse({
    required String courseCode,
    required String teacherCode,
  }) async {
    try {
      _setLoading(true);

      await EnrollmentService.joinCourse(
        courseCode: courseCode,
        teacherCode: teacherCode,
      );

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Student Courses
  Stream<List<EnrollmentModel>> getStudentCourses() {
    return EnrollmentService.getStudentCourses();
  }
}