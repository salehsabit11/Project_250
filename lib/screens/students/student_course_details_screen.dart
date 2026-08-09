import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/course_model.dart';
import '../../models/student_course_summary_model.dart';
import '../../providers/attendance_record_provider.dart';

class StudentCourseDetailsScreen extends StatelessWidget {
  final CourseModel course;

  const StudentCourseDetailsScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final attendanceProvider =
        Provider.of<AttendanceRecordProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(course.courseCode),
        centerTitle: true,
      ),
      body: StreamBuilder<StudentCourseSummaryModel>(
        stream: attendanceProvider.getStudentCourseSummary(
          courseId: course.id,
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
                ),
              ),
            );
          }

          final summary = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              //-------------------------------------------------
              // COURSE INFORMATION
              //-------------------------------------------------

              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        course.courseName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Course Code : ${course.courseCode}",
                      ),

                      Text(
                        "Department : ${course.department}",
                      ),

                      Text(
                        "Semester : ${course.semester}",
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //-------------------------------------------------
              // ATTENDANCE SUMMARY
              //-------------------------------------------------

              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Attendance Summary",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        "Total Classes : ${summary.totalClasses}",
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Present : ${summary.totalPresent}",
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Absent : ${summary.totalAbsent}",
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Attendance : ${summary.attendancePercentage.toStringAsFixed(2)} %",
                      ),

                      const SizedBox(height: 20),

                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(10),
                        child:
                            LinearProgressIndicator(
                          minHeight: 12,
                          value: summary.totalClasses == 0
                              ? 0
                              : summary.totalPresent /
                                  summary.totalClasses,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Attendance History",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              if (summary.records.isEmpty)
                const Center(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 40),
                    child: Text(
                      "No attendance records found.",
                    ),
                  ),
                )
              else
                ...summary.records.map((record) {
                  return Card(
                    margin:
                        const EdgeInsets.only(
                            bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          "${record.classNumber}",
                        ),
                      ),
                      title: Text(
                        "Class ${record.classNumber}",
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat(
                          "dd MMM yyyy   hh:mm a",
                        ).format(
                          record.attendanceTime,
                        ),
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