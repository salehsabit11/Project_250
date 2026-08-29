import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/attendance_record_model.dart';
import '../models/attendance_session_model.dart';
import '../models/student_attendance_summary.dart';
import '../models/course_statistics_model.dart';
import '../models/class_session_model.dart';
import '../models/student_course_summary_model.dart';

class AttendanceRecordService {
  AttendanceRecordService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ==========================================================
  // STUDENT
  // MARK ATTENDANCE THROUGH QR
  // ==========================================================

  static Future<void> markAttendance({
    required AttendanceSessionModel session,
  }) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception("User not logged in.");
    }

    // Check session status
    if (!session.isActive) {
      throw Exception(
        "This attendance class has already ended.",
      );
    }

    // Check QR expiration
    if (DateTime.now().isAfter(session.endTime)) {
      throw Exception(
        "This QR code has expired.",
      );
    }

    // ----------------------------------------------------------
    // Get student information
    // ----------------------------------------------------------

    final studentDoc = await _firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .get();

    if (!studentDoc.exists) {
      throw Exception(
        "Student not found.",
      );
    }

    final student = studentDoc.data()!;

    final regNo = student["studentId"] ?? "";

    if (regNo.toString().isEmpty) {
      throw Exception(
        "Student registration number not found.",
      );
    }

    // ----------------------------------------------------------
    // Check enrollment
    // ----------------------------------------------------------

    final enrollment = await _firestore
        .collection("course_enrollments")
        .where(
          "courseId",
          isEqualTo: session.courseId,
        )
        .where(
          "studentId",
          isEqualTo: firebaseUser.uid,
        )
        .limit(1)
        .get();

    if (enrollment.docs.isEmpty) {
      throw Exception(
        "You are not enrolled in this course.",
      );
    }

    // ----------------------------------------------------------
    // Prevent duplicate attendance
    // ----------------------------------------------------------

    final duplicate = await _firestore
        .collection("attendance_records")
        .where(
          "sessionId",
          isEqualTo: session.id,
        )
        .where(
          "studentUid",
          isEqualTo: firebaseUser.uid,
        )
        .limit(1)
        .get();

    if (duplicate.docs.isNotEmpty) {
      throw Exception(
        "Attendance already marked for this class.",
      );
    }

    // ----------------------------------------------------------
    // Create attendance record
    // ----------------------------------------------------------

    final doc = _firestore
        .collection("attendance_records")
        .doc();

    final record = AttendanceRecordModel(
      id: doc.id,

      sessionId: session.id,
      classNumber: session.classNumber,

      courseId: session.courseId,
      courseName: session.courseName,
      courseCode: session.courseCode,

      teacherUid: session.teacherUid,

      studentUid: firebaseUser.uid,
      studentId: regNo.toString(),

      studentName:
          student["fullName"] ?? "",

      studentEmail:
          student["email"] ?? "",

      attendanceTime:
          DateTime.now(),

      // QR attendance is automatically present
      status: "present",
    );

    await doc.set(
      record.toMap(),
    );
  }

  // ==========================================================
  // TEACHER
  // GET ALL ENROLLED STUDENTS OF A COURSE
  // ==========================================================

  static Stream<List<Map<String, dynamic>>> getCourseStudents(
    String courseId,
  ) {
    return _firestore
        .collection("course_enrollments")
        .where(
          "courseId",
          isEqualTo: courseId,
        )
        .snapshots()
        .asyncMap(
      (snapshot) async {
        final List<Map<String, dynamic>> students = [];

        for (final enrollmentDoc in snapshot.docs) {
          final enrollment =
              enrollmentDoc.data();

          final studentUid =
              enrollment["studentId"];

          if (studentUid == null) {
            continue;
          }

          final studentDoc = await _firestore
              .collection("users")
              .doc(studentUid)
              .get();

          if (!studentDoc.exists) {
            continue;
          }

          final student =
              studentDoc.data()!;

          students.add({
            "uid": studentUid,
            "studentId":
                student["studentId"] ?? "",
            "fullName":
                student["fullName"] ?? "",
            "email":
                student["email"] ?? "",
            "department":
                student["department"] ?? "",
          });
        }

        students.sort(
          (a, b) => a["studentId"]
              .toString()
              .compareTo(
                b["studentId"].toString(),
              ),
        );

        return students;
      },
    );
  }

  // ==========================================================
  // TEACHER
  // FIND STUDENT BY UNIVERSITY STUDENT ID
  // ==========================================================

  static Future<Map<String, dynamic>?>
      findStudentById(
    String studentId,
  ) async {
    final snapshot = await _firestore
        .collection("users")
        .where(
          "studentId",
          isEqualTo: studentId,
        )
        .where(
          "role",
          isEqualTo: "student",
        )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final data =
        snapshot.docs.first.data();

    return {
      "uid": data["uid"] ?? "",
      "studentId":
          data["studentId"] ?? "",
      "fullName":
          data["fullName"] ?? "",
      "email":
          data["email"] ?? "",
      "department":
          data["department"] ?? "",
      "semester":
          data["semester"] ?? "",
    };
  }

  // ==========================================================
  // TEACHER
  // ADD STUDENT TO COURSE
  // ==========================================================

  static Future<void> addStudentToCourse({
    required String courseId,
    required String courseName,
    required String courseCode,
    required String teacherUid,
    required String teacherCode,
    required String studentUid,
  }) async {
    // ----------------------------------------------------------
    // Check whether student already enrolled
    // ----------------------------------------------------------

    final existingEnrollment =
        await _firestore
            .collection("course_enrollments")
            .where(
              "courseId",
              isEqualTo: courseId,
            )
            .where(
              "studentId",
              isEqualTo: studentUid,
            )
            .limit(1)
            .get();

    if (existingEnrollment.docs.isNotEmpty) {
      throw Exception(
        "Student is already enrolled in this course.",
      );
    }

    // ----------------------------------------------------------
    // Get student information
    // ----------------------------------------------------------

    final studentDoc = await _firestore
        .collection("users")
        .doc(studentUid)
        .get();

    if (!studentDoc.exists) {
      throw Exception(
        "Student account not found.",
      );
    }

    final student =
        studentDoc.data()!;

    // ----------------------------------------------------------
    // Create enrollment
    // ----------------------------------------------------------

    final enrollmentDoc =
        _firestore
            .collection("course_enrollments")
            .doc();

    await enrollmentDoc.set({
      "id": enrollmentDoc.id,

      "courseId": courseId,
      "courseName": courseName,
      "courseCode": courseCode,

      "teacherCode": teacherCode,

      "studentId": studentUid,

      "studentName":
          student["fullName"] ?? "",

      "studentEmail":
          student["email"] ?? "",

      "joinedAt":
          Timestamp.now(),
    });
  }

  // ==========================================================
  // TEACHER
  // MARK STUDENT PRESENT MANUALLY
  // ==========================================================
// ==========================================================
// TEACHER
// MANUALLY MARK STUDENT PRESENT / ABSENT
// ==========================================================

static Future<void> markStudentAttendanceManually({
  required AttendanceSessionModel session,
  required String studentUid,
  required String status,
}) async {
  // --------------------------------------------------------
  // Make sure teacher is logged in
  // --------------------------------------------------------

  final teacher = _auth.currentUser;

  if (teacher == null) {
    throw Exception(
      "Teacher not logged in.",
    );
  }

  // --------------------------------------------------------
  // Validate attendance status
  // --------------------------------------------------------

  if (status != "present" && status != "absent") {
    throw Exception(
      "Invalid attendance status.",
    );
  }

  // --------------------------------------------------------
  // Make sure this session belongs to this teacher
  // --------------------------------------------------------

  if (session.teacherUid != teacher.uid) {
    throw Exception(
      "You are not authorized to edit this attendance.",
    );
  }

  // --------------------------------------------------------
  // Check if attendance record already exists
  // --------------------------------------------------------

  final duplicate = await _firestore
      .collection("attendance_records")
      .where(
        "sessionId",
        isEqualTo: session.id,
      )
      .where(
        "studentUid",
        isEqualTo: studentUid,
      )
      .limit(1)
      .get();

  // --------------------------------------------------------
  // If record already exists
  // simply update its status
  // --------------------------------------------------------

  if (duplicate.docs.isNotEmpty) {
    final recordId = duplicate.docs.first.id;

    await _firestore
        .collection("attendance_records")
        .doc(recordId)
        .update({
      "status": status,
      "attendanceTime": Timestamp.now(),
    });

    return;
  }

  // --------------------------------------------------------
  // Get student information
  // --------------------------------------------------------

  final studentDoc = await _firestore
      .collection("users")
      .doc(studentUid)
      .get();

  if (!studentDoc.exists) {
    throw Exception(
      "Student not found.",
    );
  }

  final student = studentDoc.data()!;

  // --------------------------------------------------------
  // Create a new attendance record
  // --------------------------------------------------------

  final doc = _firestore
      .collection("attendance_records")
      .doc();

  final record = AttendanceRecordModel(
    id: doc.id,

    sessionId: session.id,

    classNumber: session.classNumber,

    courseId: session.courseId,

    courseName: session.courseName,

    courseCode: session.courseCode,

    teacherUid: session.teacherUid,

    studentUid: studentUid,

    studentId:
        student["studentId"]?.toString() ?? "",

    studentName:
        student["fullName"]?.toString() ?? "",

    studentEmail:
        student["email"]?.toString() ?? "",

    attendanceTime: DateTime.now(),

    status: status,
  );

  await doc.set(
    record.toMap(),
  );
}

  // ==========================================================
  // TEACHER
  // UPDATE ATTENDANCE STATUS
  // ==========================================================

  static Future<void>
      updateAttendanceStatus({
    required String recordId,
    required String status,
  }) async {
    final teacher =
        _auth.currentUser;

    if (teacher == null) {
      throw Exception(
        "Teacher not logged in.",
      );
    }

    if (status != "present" &&
        status != "absent") {
      throw Exception(
        "Invalid attendance status.",
      );
    }

    final recordDoc =
        await _firestore
            .collection("attendance_records")
            .doc(recordId)
            .get();

    if (!recordDoc.exists) {
      throw Exception(
        "Attendance record not found.",
      );
    }

    final record =
        recordDoc.data()!;

    // Only the teacher of this course
    // can edit the record.
    if (record["teacherUid"] !=
        teacher.uid) {
      throw Exception(
        "You are not authorized to edit this attendance.",
      );
    }

    await _firestore
        .collection("attendance_records")
        .doc(recordId)
        .update({
      "status": status,
      "attendanceTime":
          Timestamp.now(),
    });
  }

  // ==========================================================
  // TEACHER
  // GET ATTENDANCE OF ONE CLASS SESSION
  // ==========================================================

  static Stream<
      List<AttendanceRecordModel>>
      getSessionAttendance(
    String sessionId,
  ) {
    return _firestore
        .collection("attendance_records")
        .where(
          "sessionId",
          isEqualTo: sessionId,
        )
        .snapshots()
        .map(
      (snapshot) {
        final records = snapshot.docs
            .map(
              (doc) =>
                  AttendanceRecordModel
                      .fromMap(
                doc.data(),
              ),
            )
            .toList();

        records.sort(
          (a, b) => a.studentId
              .compareTo(b.studentId),
        );

        return records;
      },
    );
  }

  // ==========================================================
  // TEACHER
  // RAW ATTENDANCE RECORDS
  // ==========================================================

  static Stream<
      List<AttendanceRecordModel>>
      getCourseAttendance(
    String courseId,
  ) {
    return _firestore
        .collection("attendance_records")
        .where(
          "courseId",
          isEqualTo: courseId,
        )
        .snapshots()
        .map(
      (snapshot) {
        final records = snapshot.docs
            .map(
              (doc) =>
                  AttendanceRecordModel
                      .fromMap(
                doc.data(),
              ),
            )
            .toList();

        records.sort(
          (a, b) => a.studentId
              .compareTo(b.studentId),
        );

        return records;
      },
    );
  }

  // ==========================================================
  // TEACHER
  // ATTENDANCE SUMMARY
  // ==========================================================

  static Stream<
      List<StudentAttendanceSummary>>
      getCourseAttendanceSummary(
    String courseId,
  ) {
    return _firestore
        .collection("attendance_records")
        .where(
          "courseId",
          isEqualTo: courseId,
        )
        .snapshots()
        .map(
      (snapshot) {
        final Map<
            String,
            List<AttendanceRecordModel>>
            groupedStudents = {};

        for (final doc
            in snapshot.docs) {
          final record =
              AttendanceRecordModel
                  .fromMap(
            doc.data(),
          );

          groupedStudents
              .putIfAbsent(
            record.studentUid,
            () => [],
          )
              .add(record);
        }

        final List<
            StudentAttendanceSummary>
            summaries = [];

        groupedStudents.forEach(
          (uid, records) {
            records.sort(
              (a, b) => b.attendanceTime
                  .compareTo(
                a.attendanceTime,
              ),
            );

            final latest =
                records.first;

            final totalPresent =
                records
                    .where(
                      (record) =>
                          record.status ==
                          "present",
                    )
                    .length;

            summaries.add(
              StudentAttendanceSummary(
                studentUid:
                    latest.studentUid,
                studentId:
                    latest.studentId,
                studentName:
                    latest.studentName,
                studentEmail:
                    latest.studentEmail,
                totalPresent:
                    totalPresent,
                lastAttendance:
                    latest.attendanceTime,
              ),
            );
          },
        );

        summaries.sort(
          (a, b) => a.studentId
              .compareTo(b.studentId),
        );

        return summaries;
      },
    );
  }

  // ==========================================================
  // STUDENT
  // ATTENDANCE HISTORY
  // ==========================================================

  static Stream<
      List<AttendanceRecordModel>>
      getStudentAttendance() {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection("attendance_records")
        .where(
          "studentUid",
          isEqualTo:
              firebaseUser.uid,
        )
        .snapshots()
        .map(
      (snapshot) {
        final records = snapshot.docs
            .map(
              (doc) =>
                  AttendanceRecordModel
                      .fromMap(
                doc.data(),
              ),
            )
            .toList();

        records.sort(
          (a, b) => b.attendanceTime
              .compareTo(
            a.attendanceTime,
          ),
        );

        return records;
      },
    );
  }

  // ==========================================================
  // TEACHER
  // ONE STUDENT ATTENDANCE HISTORY
  // ==========================================================

  static Stream<
      List<AttendanceRecordModel>>
      getStudentCourseAttendance({
    required String courseId,
    required String studentUid,
  }) {
    return _firestore
        .collection("attendance_records")
        .where(
          "courseId",
          isEqualTo: courseId,
        )
        .where(
          "studentUid",
          isEqualTo: studentUid,
        )
        .snapshots()
        .map(
      (snapshot) {
        final records = snapshot.docs
            .map(
              (doc) =>
                  AttendanceRecordModel
                      .fromMap(
                doc.data(),
              ),
            )
            .toList();

        records.sort(
          (a, b) => b.attendanceTime
              .compareTo(
            a.attendanceTime,
          ),
        );

        return records;
      },
    );
  }

  // ==========================================================
  // TEACHER
  // COURSE STATISTICS
  // ==========================================================

  static Stream<
      List<CourseStatisticsModel>>
      getCourseStatistics(
    String courseId,
  ) {
    return _firestore
        .collection("attendance_sessions")
        .where(
          "courseId",
          isEqualTo: courseId,
        )
        .snapshots()
        .asyncMap(
      (sessionSnapshot) async {
        final totalClasses =
            sessionSnapshot.docs.length;

        final attendanceSnapshot =
            await _firestore
                .collection(
                  "attendance_records",
                )
                .where(
                  "courseId",
                  isEqualTo:
                      courseId,
                )
                .get();

        final Map<
            String,
            List<AttendanceRecordModel>>
            grouped = {};

        for (final doc
            in attendanceSnapshot.docs) {
          final record =
              AttendanceRecordModel
                  .fromMap(
            doc.data(),
          );

          grouped.putIfAbsent(
            record.studentUid,
            () => [],
          ).add(record);
        }

        final List<
            CourseStatisticsModel>
            statistics = [];

        grouped.forEach(
          (uid, records) {
            final first =
                records.first;

            final totalPresent =
                records
                    .where(
                      (record) =>
                          record.status ==
                          "present",
                    )
                    .length;

            statistics.add(
              CourseStatisticsModel(
                studentUid:
                    first.studentUid,
                studentId:
                    first.studentId,
                studentName:
                    first.studentName,
                studentEmail:
                    first.studentEmail,
                totalPresent:
                    totalPresent,
                totalClasses:
                    totalClasses,
              ),
            );
          },
        );

        statistics.sort(
          (a, b) => a.studentId
              .compareTo(
            b.studentId,
          ),
        );

        return statistics;
      },
    );
  }

  // ==========================================================
  // TEACHER
  // GET ALL CLASS SESSIONS
  // ==========================================================

  static Stream<
      List<ClassSessionModel>>
      getCourseClassSessions(
    String courseId,
  ) {
    return _firestore
        .collection("attendance_sessions")
        .where(
          "courseId",
          isEqualTo: courseId,
        )
        .orderBy("classNumber")
        .snapshots()
        .asyncMap(
      (sessionSnapshot) async {
        final List<
            ClassSessionModel>
            classes = [];

        for (final sessionDoc
            in sessionSnapshot.docs) {
          final data =
              sessionDoc.data();

          final attendanceSnapshot =
              await _firestore
                  .collection(
                    "attendance_records",
                  )
                  .where(
                    "sessionId",
                    isEqualTo:
                        sessionDoc.id,
                  )
                  .get();

          final totalPresent =
              attendanceSnapshot.docs
                  .map(
                    (doc) =>
                        AttendanceRecordModel
                            .fromMap(
                      doc.data(),
                    ),
                  )
                  .where(
                    (record) =>
                        record.status ==
                        "present",
                  )
                  .length;

          classes.add(
            ClassSessionModel(
              sessionId:
                  sessionDoc.id,
              classNumber:
                  data["classNumber"] ??
                      1,
              classDate:
                  (data["startTime"]
                          as Timestamp)
                      .toDate(),
              totalPresent:
                  totalPresent,
            ),
          );
        }

        classes.sort(
          (a, b) => a.classNumber
              .compareTo(
            b.classNumber,
          ),
        );

        return classes;
      },
    );
  }

  // ==========================================================
  // STUDENT
  // COURSE ATTENDANCE SUMMARY
  // ==========================================================

  static Stream<
      StudentCourseSummaryModel>
      getStudentCourseSummary({
    required String courseId,
  }) {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      return Stream.value(
        const StudentCourseSummaryModel(
          totalClasses: 0,
          totalPresent: 0,
          records: [],
        ),
      );
    }

    return _firestore
        .collection("attendance_sessions")
        .where(
          "courseId",
          isEqualTo: courseId,
        )
        .snapshots()
        .asyncMap(
      (sessionSnapshot) async {
        final totalClasses =
            sessionSnapshot.docs.length;

        final attendanceSnapshot =
            await _firestore
                .collection(
                  "attendance_records",
                )
                .where(
                  "courseId",
                  isEqualTo:
                      courseId,
                )
                .where(
                  "studentUid",
                  isEqualTo:
                      firebaseUser.uid,
                )
                .get();

        final records =
            attendanceSnapshot.docs
                .map(
                  (doc) =>
                      AttendanceRecordModel
                          .fromMap(
                    doc.data(),
                  ),
                )
                .toList();

        records.sort(
          (a, b) => b.attendanceTime
              .compareTo(
            a.attendanceTime,
          ),
        );

        final totalPresent =
            records
                .where(
                  (record) =>
                      record.status ==
                      "present",
                )
                .length;

        return StudentCourseSummaryModel(
          totalClasses:
              totalClasses,
          totalPresent:
              totalPresent,
          records:
              records,
        );
      },
    );
  }
}