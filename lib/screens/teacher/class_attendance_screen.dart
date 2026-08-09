import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/attendance_record_model.dart';
import '../../models/class_session_model.dart';
import '../../models/course_model.dart';
import '../../providers/attendance_record_provider.dart';

class ClassAttendanceScreen extends StatelessWidget {
  final CourseModel course;
  final ClassSessionModel session;

  const ClassAttendanceScreen({
    super.key,
    required this.course,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final attendanceProvider =
        Provider.of<AttendanceRecordProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Class ${session.classNumber}"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<AttendanceRecordModel>>(
        stream: attendanceProvider.getSessionAttendance(
          session.sessionId,
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

          final students = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              /// ===============================
              /// Session Header
              /// ===============================
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(18),
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

                      const SizedBox(height: 8),

                      Text(
                        "Course Code : ${course.courseCode}",
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Class No : ${session.classNumber}",
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Date : ${DateFormat("dd MMM yyyy").format(session.classDate)}",
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Time : ${DateFormat("hh:mm a").format(session.classDate)}",
                      ),

                      const SizedBox(height: 15),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Colors.green.shade50,
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),
                        child: Text(
                          "Present Students : ${students.length}",
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (students.isEmpty)
                const Center(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 80),
                    child: Text(
                      "No students attended this class.",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(
                  students.length,
                  (index) {
                    final student =
                        students[index];

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 14,
                      ),
                      elevation: 3,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            "${index + 1}",
                          ),
                        ),

                        title: Text(
                          student.studentName,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [

                            const SizedBox(
                                height: 4),

                            Text(
                              "Registration : ${student.studentId}",
                            ),

                            Text(
                              DateFormat(
                                "hh:mm a",
                              ).format(
                                student
                                    .attendanceTime,
                              ),
                            ),
                          ],
                        ),

                        trailing: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),

                        isThreeLine: true,
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}