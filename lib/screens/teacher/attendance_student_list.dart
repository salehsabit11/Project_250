import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/attendance_record_model.dart';
import '../../models/attendance_session_model.dart';
import '../../models/class_session_model.dart';

import '../../providers/attendance_record_provider.dart';

import '../../services/attendance_service.dart';

class AttendanceStudentList extends StatelessWidget {
  final String courseId;
  final ClassSessionModel classSession;

  const AttendanceStudentList({
    super.key,
    required this.courseId,
    required this.classSession,
  });

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<AttendanceRecordProvider>(context);

    // ==========================================================
    // GET ALL ENROLLED STUDENTS
    // ==========================================================

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: provider.getCourseStudents(courseId),
      builder: (context, studentSnapshot) {
        if (studentSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (studentSnapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                studentSnapshot.error.toString(),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final students = studentSnapshot.data ?? [];

        // ========================================================
        // GET ATTENDANCE RECORDS FOR SELECTED CLASS
        // ========================================================

        return StreamBuilder<List<AttendanceRecordModel>>(
          stream: provider.getSessionAttendance(
            classSession.sessionId,
          ),
          builder: (context, attendanceSnapshot) {
            if (attendanceSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (attendanceSnapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    attendanceSnapshot.error.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final records =
                attendanceSnapshot.data ?? [];

            // ====================================================
            // CREATE ATTENDANCE LOOKUP
            //
            // student UID -> attendance record
            // ====================================================

            final Map<String, AttendanceRecordModel>
                attendanceMap = {};

            for (final record in records) {
              attendanceMap[record.studentUid] = record;
            }

            // ====================================================
            // COUNT PRESENT
            // ====================================================

            int presentCount = 0;

            for (final student in students) {
              final uid =
                  student["uid"]?.toString() ?? "";

              final record = attendanceMap[uid];

              if (record != null &&
                  record.status == "present") {
                presentCount++;
              }
            }

            // ====================================================
            // COUNT ABSENT
            // ====================================================

            final absentCount =
                students.length - presentCount;

            // ====================================================
            // UI
            // ====================================================

            return Column(
              children: [
                // =================================================
                // SUMMARY CARDS
                // =================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: "Enrolled",
                          value: students.length,
                          icon: Icons.people,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: _SummaryCard(
                          title: "Present",
                          value: presentCount,
                          icon: Icons.check_circle,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: _SummaryCard(
                          title: "Absent",
                          value: absentCount,
                          icon: Icons.cancel,
                        ),
                      ),
                    ],
                  ),
                ),

                // =================================================
                // STUDENT LIST
                // =================================================

                Expanded(
                  child: students.isEmpty
                      ? const Center(
                          child: Text(
                            "No students enrolled in this course.",
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            20,
                          ),
                          itemCount: students.length,
                          itemBuilder:
                              (context, index) {
                            final student =
                                students[index];

                            final studentUid =
                                student["uid"]
                                        ?.toString() ??
                                    "";

                            final record =
                                attendanceMap[
                                    studentUid];

                            final status =
                                record?.status ??
                                    "absent";

                            return _StudentCard(
                              student: student,
                              status: status,
                              onChangeStatus:
                                  (newStatus) async {
                                await _changeStatus(
                                  context,
                                  studentUid,
                                  record,
                                  newStatus,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // CHANGE STUDENT ATTENDANCE
  // ==========================================================

  Future<void> _changeStatus(
    BuildContext context,
    String studentUid,
    AttendanceRecordModel? record,
    String status,
  ) async {
    final provider =
        Provider.of<AttendanceRecordProvider>(
      context,
      listen: false,
    );

    String? error;

    try {
      // ========================================================
      // STUDENT DOES NOT HAVE A RECORD YET
      // ========================================================

      if (record == null) {
        // Get actual AttendanceSessionModel
        final AttendanceSessionModel?
            attendanceSession =
            await AttendanceService.getSession(
          classSession.sessionId,
        );

        if (attendanceSession == null) {
          throw Exception(
            "Attendance session not found.",
          );
        }

        // Create new attendance record
        error =
            await provider.markStudentAttendanceManually(
          session: attendanceSession,
          studentUid: studentUid,
          status: status,
        );
      }

      // ========================================================
      // STUDENT ALREADY HAS A RECORD
      // ========================================================

      else {
        error =
            await provider.updateAttendanceStatus(
          recordId: record.id,
          status: status,
        );
      }
    } catch (e) {
      error = e.toString();
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ??
              (status == "present"
                  ? "Student marked present."
                  : "Student marked absent."),
        ),
      ),
    );
  }
}

// =============================================================
// SUMMARY CARD
// =============================================================

class _SummaryCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Icon(icon),

            const SizedBox(height: 5),

            Text(
              "$value",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// STUDENT CARD
// =============================================================

class _StudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final String status;

  final Future<void> Function(
    String status,
  ) onChangeStatus;

  const _StudentCard({
    required this.student,
    required this.status,
    required this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        student["fullName"]?.toString() ?? "";

    final studentId =
        student["studentId"]?.toString() ?? "";

    final email =
        student["email"]?.toString() ?? "";

    final isPresent = status == "present";

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      elevation: 3,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Row(
          children: [
            // ===================================================
            // AVATAR
            // ===================================================

            CircleAvatar(
              radius: 25,

              child: Text(
                name.isNotEmpty
                    ? name[0].toUpperCase()
                    : "?",

                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ===================================================
            // STUDENT INFORMATION
            // ===================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    name,

                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "ID: $studentId",
                  ),

                  if (email.isNotEmpty)
                    Text(
                      email,

                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),

                  const SizedBox(height: 6),

                  Text(
                    isPresent
                        ? "Present"
                        : "Absent",

                    style: TextStyle(
                      color: isPresent
                          ? Colors.green
                          : Colors.red,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ===================================================
            // CHANGE STATUS
            // ===================================================

            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
              ),

              onSelected:
                  onChangeStatus,

              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: "present",

                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: Colors.green,
                        ),

                        SizedBox(width: 8),

                        Text(
                          "Present",
                        ),
                      ],
                    ),
                  ),

                  PopupMenuItem(
                    value: "absent",

                    child: Row(
                      children: [
                        Icon(
                          Icons.close,
                          color: Colors.red,
                        ),

                        SizedBox(width: 8),

                        Text(
                          "Absent",
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}