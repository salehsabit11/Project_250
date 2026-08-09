import 'attendance_record_model.dart';

class StudentCourseSummaryModel {
  final int totalClasses;
  final int totalPresent;

  /// Complete attendance history
  final List<AttendanceRecordModel> records;

  const StudentCourseSummaryModel({
    required this.totalClasses,
    required this.totalPresent,
    required this.records,
  });

  int get totalAbsent => totalClasses - totalPresent;

  double get attendancePercentage {
    if (totalClasses == 0) return 0;
    return (totalPresent / totalClasses) * 100;
  }
}