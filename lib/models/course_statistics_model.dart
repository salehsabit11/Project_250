class CourseStatisticsModel {
  final String studentUid;
  final String studentId;
  final String studentName;
  final String studentEmail;

  final int totalPresent;
  final int totalClasses;

  const CourseStatisticsModel({
    required this.studentUid,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.totalPresent,
    required this.totalClasses,
  });

  double get attendancePercentage {
    if (totalClasses == 0) return 0;
    return (totalPresent / totalClasses) * 100;
  }

  String get attendanceText {
    return "$totalPresent/$totalClasses";
  }
}