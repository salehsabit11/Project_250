import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/course_model.dart';

class CourseService {
  CourseService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  /// Create a new course
  static Future<void> createCourse({
    required String courseName,
    required String courseCode,
    required String department,
    required String semester,
  }) async {
    final teacher = _auth.currentUser;

    if (teacher == null) {
      throw Exception("No logged in teacher.");
    }

    // Get teacher information
    final teacherDoc = await _firestore
        .collection("users")
        .doc(teacher.uid)
        .get();

    if (!teacherDoc.exists) {
      throw Exception("Teacher information not found.");
    }

    final teacherData = teacherDoc.data()!;

    final doc = _firestore.collection("courses").doc();

    final course = CourseModel(
      id: doc.id,
      courseName: courseName,
      courseCode: courseCode.toUpperCase(),
      department: department,
      semester: semester,

      // Firebase Authentication UID
      teacherUid: teacher.uid,

      // Teacher ID entered during registration
      teacherCode: teacherData["teacherId"],

      // Teacher full name
      teacherName: teacherData["fullName"],

      createdAt: DateTime.now(),
    );

    await doc.set(course.toMap());
  }

  /// Get all courses created by the current teacher
  static Stream<List<CourseModel>> getTeacherCourses() {
    final teacher = _auth.currentUser;

    if (teacher == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection("courses")
        .where("teacherUid", isEqualTo: teacher.uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CourseModel.fromMap(doc.data()))
              .toList(),
        );
  }
  /// ==========================================================
/// Get Single Course
/// ==========================================================
static Future<CourseModel> getCourseById(
  String courseId,
) async {
  final doc = await _firestore
      .collection("courses")
      .doc(courseId)
      .get();

  if (!doc.exists) {
    throw Exception("Course not found.");
  }

  return CourseModel.fromMap(doc.data()!);
}

  /// Delete a course
  static Future<void> deleteCourse(String courseId) async {
    await _firestore
        .collection("courses")
        .doc(courseId)
        .delete();
  }
}