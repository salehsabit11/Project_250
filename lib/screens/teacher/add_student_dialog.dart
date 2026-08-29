import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course_model.dart';
import '../../providers/attendance_record_provider.dart';
import '../../services/auth_service.dart';

class AddStudentDialog extends StatefulWidget {
  final CourseModel course;

  const AddStudentDialog({
    super.key,
    required this.course,
  });

  @override
  State<AddStudentDialog> createState() =>
      _AddStudentDialogState();
}

class _AddStudentDialogState
    extends State<AddStudentDialog> {

  final TextEditingController
      _studentIdController =
      TextEditingController();

  Map<String, dynamic>? _foundStudent;

  bool _isSearching = false;
  bool _isAdding = false;

  String? _errorMessage;

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  // ===========================================================
  // FIND STUDENT
  // ===========================================================

  Future<void> _findStudent() async {
    final studentId =
        _studentIdController.text.trim();

    if (studentId.isEmpty) {
      setState(() {
        _errorMessage =
            "Please enter a student ID.";

        _foundStudent = null;
      });

      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _foundStudent = null;
    });

    try {
      final provider =
          Provider.of<AttendanceRecordProvider>(
        context,
        listen: false,
      );

      final student =
          await provider.findStudentById(
        studentId,
      );

      if (!mounted) {
        return;
      }

      if (student == null) {
        setState(() {
          _isSearching = false;
          _foundStudent = null;

          _errorMessage =
              "No student found with this ID.";
        });

        return;
      }

      setState(() {
        _isSearching = false;
        _foundStudent = student;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSearching = false;
        _foundStudent = null;

        _errorMessage =
            e.toString();
      });
    }
  }

  // ===========================================================
  // ADD STUDENT
  // ===========================================================

  Future<void> _addStudent() async {
    if (_foundStudent == null) {
      return;
    }

    setState(() {
      _isAdding = true;
      _errorMessage = null;
    });

    try {
      // ========================================================
      // TEACHER
      // ========================================================

      final teacher =
          FirebaseAuth.instance.currentUser;

      if (teacher == null) {
        throw Exception(
          "Teacher is not logged in.",
        );
      }

      // ========================================================
      // GET TEACHER CODE
      // ========================================================

      final teacherCode =
          await AuthService.getTeacherCode();

      if (!mounted) {
        return;
      }

      // ========================================================
      // PROVIDER
      // ========================================================

      final provider =
          Provider.of<AttendanceRecordProvider>(
        context,
        listen: false,
      );

      // ========================================================
      // ADD STUDENT
      // ========================================================

      final error =
          await provider.addStudentToCourse(
        courseId:
            widget.course.id,

        courseName:
            widget.course.courseName,

        courseCode:
            widget.course.courseCode,

        teacherUid:
            teacher.uid,

        teacherCode:
            teacherCode,

        studentUid:
            _foundStudent!["uid"]
                .toString(),
      );

      if (!mounted) {
        return;
      }

      if (error != null) {
        setState(() {
          _isAdding = false;

          _errorMessage = error;
        });

        return;
      }

      // ========================================================
      // SUCCESS
      // ========================================================

      Navigator.of(context).pop(true);

    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isAdding = false;

        _errorMessage =
            e.toString();
      });
    }
  }

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Add Student Manually",
      ),

      content: SizedBox(
        width: 420,

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const Text(
                "Enter the student's university "
                "registration ID.",
              ),

              const SizedBox(height: 16),

              // =================================================
              // STUDENT ID
              // =================================================

              TextField(
                controller:
                    _studentIdController,

                enabled:
                    !_isAdding,

                decoration:
                    const InputDecoration(
                  labelText:
                      "Student ID",

                  hintText:
                      "Example: 202312345",

                  prefixIcon:
                      Icon(Icons.badge),

                  border:
                      OutlineInputBorder(),
                ),

                onSubmitted: (_) {
                  if (!_isSearching &&
                      !_isAdding) {
                    _findStudent();
                  }
                },
              ),

              const SizedBox(height: 12),

              // =================================================
              // FIND BUTTON
              // =================================================

              SizedBox(
                width: double.infinity,

                child:
                    ElevatedButton.icon(
                  onPressed:
                      _isSearching ||
                              _isAdding
                          ? null
                          : _findStudent,

                  icon:
                      _isSearching
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                              ),
                            )
                          : const Icon(
                              Icons.search,
                            ),

                  label:
                      Text(
                    _isSearching
                        ? "Searching..."
                        : "Find Student",
                  ),
                ),
              ),

              // =================================================
              // ERROR MESSAGE
              // =================================================

              if (_errorMessage != null)
                Container(
                  width:
                      double.infinity,

                  margin:
                      const EdgeInsets.only(
                    top: 12,
                  ),

                  padding:
                      const EdgeInsets.all(
                    12,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.red.shade50,

                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),

                    border: Border.all(
                      color:
                          Colors.red.shade200,
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Icon(
                        Icons.error_outline,
                        color:
                            Colors.red.shade700,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Expanded(
                        child: Text(
                          _errorMessage!,

                          style:
                              TextStyle(
                            color:
                                Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // =================================================
              // FOUND STUDENT
              // =================================================

              if (_foundStudent != null)
                Container(
                  width:
                      double.infinity,

                  margin:
                      const EdgeInsets.only(
                    top: 12,
                  ),

                  padding:
                      const EdgeInsets.all(
                    14,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.green.shade50,

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),

                    border: Border.all(
                      color:
                          Colors.green.shade200,
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Row(
                        children: [

                          Icon(
                            Icons
                                .check_circle,
                            color:
                                Colors.green.shade700,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          const Text(
                            "Student Found",
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Text(
                        _foundStudent![
                                    "fullName"]
                                ?.toString() ??
                            "",

                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        "ID: "
                        "${_foundStudent!["studentId"] ?? ""}",
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        _foundStudent![
                                    "email"]
                                ?.toString() ??
                            "",

                        style:
                            TextStyle(
                          color:
                              Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        "Department: "
                        "${_foundStudent!["department"] ?? ""}",

                        style:
                            const TextStyle(
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =========================================
                      // ADD STUDENT
                      // =========================================

                      SizedBox(
                        width:
                            double.infinity,

                        child:
                            ElevatedButton.icon(
                          onPressed:
                              _isAdding
                                  ? null
                                  : _addStudent,

                          icon:
                              _isAdding
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons
                                          .person_add,
                                    ),

                          label:
                              Text(
                            _isAdding
                                ? "Adding..."
                                : "Add Student",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),

      // =========================================================
      // CANCEL
      // =========================================================

      actions: [

        TextButton(
          onPressed:
              _isAdding
                  ? null
                  : () {
                      Navigator.of(
                        context,
                      ).pop(false);
                    },

          child:
              const Text(
            "Cancel",
          ),
        ),
      ],
    );
  }
}