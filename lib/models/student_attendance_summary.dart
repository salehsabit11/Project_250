class StudentAttendanceSummary {
  final String studentUid;
  final String studentId;
  final String studentName;
  final String studentEmail;

  final int totalPresent;

  final DateTime lastAttendance;

  const StudentAttendanceSummary({
    required this.studentUid,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.totalPresent,
    required this.lastAttendance,
  });
}