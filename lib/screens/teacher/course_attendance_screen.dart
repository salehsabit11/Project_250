import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course_model.dart';
import '../../models/course_statistics_model.dart';
import '../../providers/attendance_record_provider.dart';
import 'student_attendance_history_screen.dart';
import '../../services/pdf_service.dart';

class CourseAttendanceScreen extends StatelessWidget {
  final CourseModel course;

  const CourseAttendanceScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceRecordProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Course Attendance"), centerTitle: true),
      body: StreamBuilder<List<CourseStatisticsModel>>(
        stream: attendanceProvider.getCourseStatistics(course.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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

          final students = snapshot.data ?? [];

          final totalClasses = students.isEmpty
              ? 0
              : students.first.totalClasses;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// ===========================
              /// Course Header
              /// ===========================
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.courseName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Course Code : ${course.courseCode}",
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Department : ${course.department}",
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Semester : ${course.semester}",
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Students Attended : ${students.length}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Classes Conducted : $totalClasses",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ===========================
              /// EXPORT BUTTONS
              /// ===========================
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: students.isEmpty
                          ? null
                          : () async {
                              try {
                                debugPrint("1. Button clicked");

                                await PdfService.exportAttendanceReport(
                                  course: course,
                                  students: students,
                                );

                                debugPrint("2. PDF generated");

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "PDF exported successfully.",
                                      ),
                                    ),
                                  );
                                }
                              } catch (e, s) {
                                debugPrint("PDF ERROR:");
                                debugPrint(e.toString());
                                debugPrint(s.toString());

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Export PDF"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("CSV Export coming next."),
                          ),
                        );
                      },
                      icon: const Icon(Icons.table_chart),
                      label: const Text("Export CSV"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (students.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text(
                      "No attendance records yet.",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              else
                ...List.generate(students.length, (index) {
                  final student = students[index];

                  final percentage = student.attendancePercentage;

                  Color progressColor;

                  if (percentage >= 80) {
                    progressColor = Colors.green;
                  } else if (percentage >= 60) {
                    progressColor = Colors.orange;
                  } else {
                    progressColor = Colors.red;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(child: Text("${index + 1}")),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  student.studentName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Text("Registration No : ${student.studentId}"),

                          const SizedBox(height: 12),

                          Text(
                            "Present : ${student.totalPresent} / ${student.totalClasses}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Attendance : ${percentage.toStringAsFixed(1)} %",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: progressColor,
                            ),
                          ),

                          const SizedBox(height: 10),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: student.totalClasses == 0
                                  ? 0
                                  : student.totalPresent / student.totalClasses,
                              minHeight: 8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progressColor,
                              ),
                              backgroundColor: Colors.grey.shade300,
                            ),
                          ),

                          const SizedBox(height: 18),

                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        StudentAttendanceHistoryScreen(
                                          course: course,
                                          student: student,
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.history),
                              label: const Text("View History"),
                            ),
                          ),
                        ],
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
