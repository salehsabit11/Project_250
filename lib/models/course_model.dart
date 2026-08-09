import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;

  final String courseName;
  final String courseCode;

  final String department;
  final String semester;

  // Firebase Authentication UID
  final String teacherUid;

  // University Teacher ID (Example: T001)
  final String teacherCode;

  final String teacherName;

  final DateTime createdAt;

  const CourseModel({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.department,
    required this.semester,
    required this.teacherUid,
    required this.teacherCode,
    required this.teacherName,
    required this.createdAt,
  });

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] ?? '',
      courseName: map['courseName'] ?? '',
      courseCode: map['courseCode'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      teacherUid: map['teacherUid'] ?? '',
      teacherCode: map['teacherCode'] ?? '',
      teacherName: map['teacherName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseName': courseName,
      'courseCode': courseCode,
      'department': department,
      'semester': semester,
      'teacherUid': teacherUid,
      'teacherCode': teacherCode,
      'teacherName': teacherName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}