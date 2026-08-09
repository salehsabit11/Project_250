import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enrollment_model.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/course_provider.dart';

import 'student_course_details_screen.dart';

class StudentCourseScreen extends StatelessWidget {
  const StudentCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final enrollmentProvider =
        Provider.of<EnrollmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<EnrollmentModel>>(
        stream: enrollmentProvider.getStudentCourses(),
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

          final courses = snapshot.data ?? [];

          if (courses.isEmpty) {
            return const Center(
              child: Text(
                "You haven't joined any courses yet.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final enrollment = courses[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () async {
                    try {
                      final courseProvider =
                          Provider.of<CourseProvider>(
                        context,
                        listen: false,
                      );

                      final course =
                          await courseProvider.getCourseById(
                        enrollment.courseId,
                      );

                      if (!context.mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StudentCourseDetailsScreen(
                            course: course,
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              Colors.blue.shade100,
                          child: const Icon(
                            Icons.menu_book,
                            color: Colors.blue,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                enrollment.courseName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "Course Code : ${enrollment.courseCode}",
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Teacher Code : ${enrollment.teacherCode}",
                              ),

                              const SizedBox(height: 8),

                              const Text(
                                "Tap to view attendance",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                        ),
                      ],
                    ),
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