import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentModel {
  final String id;
  final String courseId;
  final String courseName;
  final String courseCode;

  // Teacher Code (e.g. 2006)
  final String teacherCode;

  final String studentId;
  final String studentName;
  final String studentEmail;

  final DateTime joinedAt;

  const EnrollmentModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.teacherCode,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.joinedAt,
  });

  factory EnrollmentModel.fromMap(Map<String, dynamic> map) {
    return EnrollmentModel(
      id: map['id'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      courseCode: map['courseCode'] ?? '',
      teacherCode: map['teacherCode'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentEmail: map['studentEmail'] ?? '',
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'teacherCode': teacherCode,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }
}