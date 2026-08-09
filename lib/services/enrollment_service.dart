import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/enrollment_model.dart';

class EnrollmentService {
  EnrollmentService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  /// Student joins a course
  static Future<void> joinCourse({
    required String courseCode,
    required String teacherCode,
  }) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception("User not logged in.");
    }

    // Get student information
    final studentDoc = await _firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .get();

    if (!studentDoc.exists) {
      throw Exception("Student information not found.");
    }

    final student = studentDoc.data()!;

    // Search course
    final courseQuery = await _firestore
        .collection("courses")
        .where(
          "courseCode",
          isEqualTo: courseCode.trim().toUpperCase(),
        )
        .where(
          "teacherCode",
          isEqualTo: teacherCode.trim(),
        )
        .limit(1)
        .get();

    if (courseQuery.docs.isEmpty) {
      throw Exception("Course not found.");
    }

    final course = courseQuery.docs.first;

    // Check duplicate enrollment
    final duplicate = await _firestore
        .collection("course_enrollments")
        .where("courseId", isEqualTo: course.id)
        .where("studentId", isEqualTo: firebaseUser.uid)
        .limit(1)
        .get();

    if (duplicate.docs.isNotEmpty) {
      throw Exception("You have already joined this course.");
    }

    // Create enrollment document
    final doc =
        _firestore.collection("course_enrollments").doc();

    final enrollment = EnrollmentModel(
      id: doc.id,
      courseId: course.id,
      courseName: course["courseName"],
      courseCode: course["courseCode"],
      teacherCode: course["teacherCode"],
      studentId: firebaseUser.uid,
      studentName: student["fullName"],
      studentEmail: student["email"],
      joinedAt: DateTime.now(),
    );

    await doc.set(enrollment.toMap());
  }

  /// Get all courses joined by the current student
  static Stream<List<EnrollmentModel>> getStudentCourses() {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      return const Stream.empty();
    }

    return _firestore
    .collection("course_enrollments")
    .where("studentId", isEqualTo: firebaseUser.uid)
    .snapshots()
    .map(
      (snapshot) => snapshot.docs
          .map((doc) => EnrollmentModel.fromMap(doc.data()))
          .toList(),
    );
  }
}