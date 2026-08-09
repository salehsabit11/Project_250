import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/attendance_record_model.dart';
import '../../models/course_model.dart';
import '../../models/course_statistics_model.dart';
import '../../providers/attendance_record_provider.dart';

class StudentAttendanceHistoryScreen extends StatelessWidget {
  final CourseModel course;
  final CourseStatisticsModel student;

  const StudentAttendanceHistoryScreen({
    super.key,
    required this.course,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final attendanceProvider =
        Provider.of<AttendanceRecordProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Attendance"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<AttendanceRecordModel>>(
        stream: attendanceProvider.getStudentCourseAttendance(
          courseId: course.id,
          studentUid: student.studentUid,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final records = snapshot.data ?? [];

          Color percentageColor;

          if (student.attendancePercentage >= 80) {
            percentageColor = Colors.green;
          } else if (student.attendancePercentage >= 60) {
            percentageColor = Colors.orange;
          } else {
            percentageColor = Colors.red;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.studentName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Registration No: ${student.studentId}",
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Email: ${student.studentEmail}",
                      ),

                      const SizedBox(height: 16),

                      Text(
                        course.courseName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "Course Code: ${course.courseCode}",
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Present : ${student.totalPresent} / ${student.totalClasses}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Attendance : ${student.attendancePercentage.toStringAsFixed(1)} %",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: percentageColor,
                              ),
                            ),

                            const SizedBox(height: 10),

                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: student.totalClasses == 0
                                    ? 0
                                    : student.totalPresent /
                                        student.totalClasses,
                                minHeight: 8,
                                valueColor:
                                    AlwaysStoppedAnimation(
                                  percentageColor,
                                ),
                                backgroundColor:
                                    Colors.grey.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Attendance History",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              if (records.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      "No attendance records found.",
                    ),
                  ),
                )
              else
                ...List.generate(records.length, (index) {
                  final record = records[index];

                  return Card(
                    margin:
                        const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text("${index + 1}"),
                      ),
                      title: Text(
                        DateFormat(
                          "dd MMM yyyy",
                        ).format(record.attendanceTime),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat(
                          "hh:mm a",
                        ).format(record.attendanceTime),
                      ),
                      trailing: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}