import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceSessionModel {
  final String id;

  final String courseId;
  final String courseName;
  final String courseCode;

  final String teacherUid;

  /// Class Number (1, 2, 3...)
  final int classNumber;

  final DateTime startTime;
  final DateTime endTime;

  final bool isActive;

  /// Current QR token
  final String qrToken;

  const AttendanceSessionModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.teacherUid,
    required this.classNumber,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.qrToken,
  });

  factory AttendanceSessionModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AttendanceSessionModel(
      id: map["id"] ?? "",
      courseId: map["courseId"] ?? "",
      courseName: map["courseName"] ?? "",
      courseCode: map["courseCode"] ?? "",
      teacherUid: map["teacherUid"] ?? "",
      classNumber: map["classNumber"] ?? 1,

      startTime:
          (map["startTime"] as Timestamp).toDate(),

      endTime:
          (map["endTime"] as Timestamp).toDate(),

      isActive: map["isActive"] ?? false,

      qrToken: map["qrToken"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "courseId": courseId,
      "courseName": courseName,
      "courseCode": courseCode,
      "teacherUid": teacherUid,
      "classNumber": classNumber,
      "startTime": Timestamp.fromDate(startTime),
      "endTime": Timestamp.fromDate(endTime),
      "isActive": isActive,
      "qrToken": qrToken,
    };
  }
}