import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final String department;
  final String? studentId;
  final String? teacherId;
  final String? semester;
  final String? designation;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.department,
    this.studentId,
    this.teacherId,
    this.semester,
    this.designation,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      department: map['department'] ?? '',
      studentId: map['studentId'],
      teacherId: map['teacherId'],
      semester: map['semester'],
      designation: map['designation'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'department': department,
      'studentId': studentId,
      'teacherId': teacherId,
      'semester': semester,
      'designation': designation,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}