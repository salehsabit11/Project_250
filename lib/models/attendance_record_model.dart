import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecordModel {
  final String id;

  final String sessionId;

  /// Class Number (1,2,3...)
  final int classNumber;

  final String courseId;
  final String courseName;
  final String courseCode;

  /// Firebase UID of the teacher
  final String teacherUid;

  /// Firebase UID of the student
  final String studentUid;

  /// University registration/student ID
  final String studentId;

  final String studentName;
  final String studentEmail;

  /// When the attendance was recorded
  final DateTime attendanceTime;

  /// Attendance status
  ///
  /// "present" = student attended
  /// "absent"  = teacher manually marked absent
  final String status;

  const AttendanceRecordModel({
    required this.id,
    required this.sessionId,
    required this.classNumber,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.teacherUid,
    required this.studentUid,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.attendanceTime,
    required this.status,
  });

  factory AttendanceRecordModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AttendanceRecordModel(
      id: map["id"] ?? "",
      sessionId: map["sessionId"] ?? "",
      classNumber: map["classNumber"] ?? 1,

      courseId: map["courseId"] ?? "",
      courseName: map["courseName"] ?? "",
      courseCode: map["courseCode"] ?? "",

      teacherUid: map["teacherUid"] ?? "",

      studentUid: map["studentUid"] ?? "",
      studentId: map["studentId"] ?? "",
      studentName: map["studentName"] ?? "",
      studentEmail: map["studentEmail"] ?? "",

      attendanceTime:
          (map["attendanceTime"] as Timestamp).toDate(),

      // Existing records that don't have status
      // will automatically be treated as present.
      status: map["status"] ?? "present",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "sessionId": sessionId,
      "classNumber": classNumber,

      "courseId": courseId,
      "courseName": courseName,
      "courseCode": courseCode,

      "teacherUid": teacherUid,

      "studentUid": studentUid,
      "studentId": studentId,
      "studentName": studentName,
      "studentEmail": studentEmail,

      "attendanceTime":
          Timestamp.fromDate(attendanceTime),

      "status": status,
    };
  }
}