import 'package:flutter/material.dart';

import '../models/course_model.dart';
import '../services/course_service.dart';

class CourseProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Create Course
  Future<String?> createCourse({
    required String courseName,
    required String courseCode,
    required String department,
    required String semester,
  }) async {
    try {
      _setLoading(true);

      await CourseService.createCourse(
        courseName: courseName,
        courseCode: courseCode,
        department: department,
        semester: semester,
      );

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Get Teacher Courses
  Stream<List<CourseModel>> getTeacherCourses() {
    return CourseService.getTeacherCourses();
  }
/// ==========================================================
/// Get Single Course
/// ==========================================================
Future<CourseModel> getCourseById(
  String courseId,
) {
  return CourseService.getCourseById(courseId);
}
  /// Delete Course
  Future<void> deleteCourse(String courseId) async {
    await CourseService.deleteCourse(courseId);
  }
}