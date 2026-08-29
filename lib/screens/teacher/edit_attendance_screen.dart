import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/class_session_model.dart';
import '../../models/course_model.dart';
import '../../providers/attendance_record_provider.dart';

import 'attendance_student_list.dart';
import 'add_student_dialog.dart';

class EditAttendanceScreen extends StatefulWidget {
  final CourseModel course;

  const EditAttendanceScreen({
    super.key,
    required this.course,
  });

  @override
  State<EditAttendanceScreen> createState() =>
      _EditAttendanceScreenState();
}

class _EditAttendanceScreenState
    extends State<EditAttendanceScreen> {
  String? _selectedSessionId;

  ClassSessionModel? _selectedClassSession;

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<AttendanceRecordProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Attendance"),
        centerTitle: true,
      ),

      body: StreamBuilder<List<ClassSessionModel>>(
        stream: provider.getCourseClassSessions(
          widget.course.id,
        ),

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

          final sessions = snapshot.data ?? [];

          // =====================================================
          // NO CLASSES
          // =====================================================

          if (sessions.isEmpty) {
            return const Center(
              child: Text(
                "No classes have been conducted yet.",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          // =====================================================
          // MAIN CONTENT
          // =====================================================

          return Column(
            children: [

              // =================================================
              // COURSE INFORMATION
              // =================================================

              Container(
                width: double.infinity,

                margin: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  12,
                ),

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.blue.shade50,

                  borderRadius:
                      BorderRadius.circular(16),

                  border: Border.all(
                    color: Colors.blue.shade100,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      widget.course.courseName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Course Code: "
                      "${widget.course.courseCode}",
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Teacher: "
                      "${widget.course.teacherName}",
                    ),
                  ],
                ),
              ),

              // =================================================
              // ADD STUDENT BUTTON
              // =================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.person_add,
                    ),

                    label: const Text(
                      "Add Student Manually",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    onPressed: () async {
                      final result =
                          await showDialog<bool>(
                        context: context,

                        barrierDismissible: false,

                        builder: (_) {
                          return AddStudentDialog(
                            course: widget.course,
                          );
                        },
                      );

                      if (!context.mounted) {
                        return;
                      }

                      if (result == true) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Student added to the course successfully.",
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // =================================================
              // CLASS DROPDOWN
              // =================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child:
                    DropdownButtonFormField<String>(
                  value: _selectedSessionId,

                  decoration:
                      const InputDecoration(
                    labelText: "Select Class",

                    prefixIcon:
                        Icon(Icons.class_),

                    border:
                        OutlineInputBorder(),
                  ),

                  items: sessions.map(
                    (classSession) {
                      return DropdownMenuItem<String>(
                        value:
                            classSession.sessionId,

                        child: Text(
                          "Class "
                          "${classSession.classNumber}"
                          " • "
                          "${_formatDate(
                            classSession.classDate,
                          )}",
                        ),
                      );
                    },
                  ).toList(),

                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    final selected =
                        sessions.firstWhere(
                      (classSession) =>
                          classSession.sessionId ==
                          value,
                    );

                    setState(() {
                      _selectedSessionId = value;

                      _selectedClassSession =
                          selected;
                    });
                  },
                ),
              ),

              const SizedBox(height: 12),

              // =================================================
              // STUDENT LIST
              // =================================================

              if (_selectedClassSession == null)

                const Expanded(
                  child: Center(
                    child: Text(
                      "Select a class to view and edit attendance.",
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )

              else

                Expanded(
                  child: AttendanceStudentList(
                    courseId:
                        widget.course.id,

                    classSession:
                        _selectedClassSession!,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ===========================================================
  // FORMAT DATE
  // ===========================================================

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}