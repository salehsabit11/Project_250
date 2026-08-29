import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course_model.dart';
import '../../providers/course_provider.dart';

import 'course_attendance_screen.dart';
import 'generate_qr_screen.dart';
import 'edit_attendance_screen.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProvider =
        Provider.of<CourseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        centerTitle: true,
      ),

      body: StreamBuilder<List<CourseModel>>(
        stream: courseProvider.getTeacherCourses(),

        builder: (context, snapshot) {
          // =====================================================
          // LOADING
          // =====================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // =====================================================
          // ERROR
          // =====================================================

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

          final courses =
              snapshot.data ?? [];

          // =====================================================
          // NO COURSES
          // =====================================================

          if (courses.isEmpty) {
            return const Center(
              child: Text(
                "No courses created yet.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          // =====================================================
          // COURSE LIST
          // =====================================================

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,

            itemBuilder: (context, index) {
              final course = courses[index];

              return Card(
                elevation: 5,

                margin:
                    const EdgeInsets.only(
                  bottom: 16,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),

                child: Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // =================================================
                      // COURSE NAME
                      // =================================================

                      Text(
                        course.courseName,

                        style:
                            const TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // =================================================
                      // COURSE CODE
                      // =================================================

                      Row(
                        children: [
                          const Icon(
                            Icons.code,
                            size: 18,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Text(
                            "Course Code: "
                            "${course.courseCode}",
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      // =================================================
                      // DEPARTMENT
                      // =================================================

                      Row(
                        children: [
                          const Icon(
                            Icons.apartment,
                            size: 18,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Text(
                            "Department: "
                            "${course.department}",
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      // =================================================
                      // SEMESTER
                      // =================================================

                      Row(
                        children: [
                          const Icon(
                            Icons.school,
                            size: 18,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Text(
                            "Semester: "
                            "${course.semester}",
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // =================================================
                      // GENERATE QR
                      // =================================================

                      SizedBox(
                        width: double.infinity,

                        child:
                            ElevatedButton.icon(
                          icon: const Icon(
                            Icons.qr_code,
                          ),

                          label: const Text(
                            "Generate QR",
                          ),

                          onPressed: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    GenerateQrScreen(
                                  course: course,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // =================================================
                      // ATTENDANCE HISTORY
                      // =================================================

                      SizedBox(
                        width: double.infinity,

                        child:
                            ElevatedButton.icon(
                          icon: const Icon(
                            Icons.history,
                          ),

                          label: const Text(
                            "Attendance",
                          ),

                          onPressed: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    CourseAttendanceScreen(
                                  course: course,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // =================================================
                      // EDIT ATTENDANCE
                      // =================================================

                      SizedBox(
                        width: double.infinity,

                        child:
                            ElevatedButton.icon(
                          icon: const Icon(
                            Icons.edit,
                          ),

                          label: const Text(
                            "Edit Attendance",
                          ),

                          onPressed: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    EditAttendanceScreen(
                                  course: course,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // =================================================
                      // DELETE COURSE
                      // =================================================

                      Align(
                        alignment:
                            Alignment.centerRight,

                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),

                          tooltip:
                              "Delete Course",

                          onPressed: () async {
                            final confirm =
                                await showDialog<bool>(
                              context: context,

                              builder:
                                  (dialogContext) {
                                return AlertDialog(
                                  title:
                                      const Text(
                                    "Delete Course",
                                  ),

                                  content:
                                      const Text(
                                    "Are you sure you want to delete this course?",
                                  ),

                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          dialogContext,
                                          false,
                                        );
                                      },

                                      child:
                                          const Text(
                                        "Cancel",
                                      ),
                                    ),

                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          dialogContext,
                                          true,
                                        );
                                      },

                                      child:
                                          const Text(
                                        "Delete",
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              await courseProvider
                                  .deleteCourse(
                                course.id,
                              );

                              if (!context.mounted) {
                                return;
                              }

                              ScaffoldMessenger
                                      .of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Course deleted successfully.",
                                  ),
                                ),
                              );
                            }
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