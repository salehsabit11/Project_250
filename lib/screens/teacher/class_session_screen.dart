import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/class_session_model.dart';
import '../../models/course_model.dart';
import '../../providers/attendance_record_provider.dart';
import 'class_attendance_screen.dart';

class ClassSessionsScreen extends StatelessWidget {
  final CourseModel course;

  const ClassSessionsScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final attendanceProvider =
        Provider.of<AttendanceRecordProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Class Sessions"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ClassSessionModel>>(
        stream: attendanceProvider.getCourseClassSessions(
          course.id,
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

          final classes = snapshot.data ?? [];

          if (classes.isEmpty) {
            return const Center(
              child: Text(
                "No classes conducted yet.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final session = classes[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Class ${session.classNumber}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        DateFormat(
                          "dd MMM yyyy   hh:mm a",
                        ).format(session.classDate),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Present Students : ${session.totalPresent}",
                      ),

                      const SizedBox(height: 18),

                      Align(
                        alignment:
                            Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.people,
                          ),
                          label: const Text(
                            "View Students",
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ClassAttendanceScreen(
                                  course: course,
                                  session: session,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}