import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'attendance_history_screen.dart';
import 'join_course_screen.dart';
import 'scan_qr_screen.dart';
import 'student_course_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 214, 228, 228),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 45, 116, 160),
        foregroundColor: const Color.fromARGB(26, 145, 49, 49),
        centerTitle: true,

        title: const Text(
          "Student Dashboard",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Color.fromARGB(255, 6, 26, 74),
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SingleChildScrollView(
        child: Column(
          children: [

            // ======================================================
            // PROFILE HEADER
            // ======================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.fromLTRB(
                20,
                25,
                20,
                30,
              ),

              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 65, 115, 165),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),

              child: Column(
                children: [

                  // Profile image
                  Container(
                    padding: const EdgeInsets.all(4),

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),

                    child: const CircleAvatar(
                      radius: 42,

                      backgroundColor: Color(0xFFE8F1FF),

                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Student name
                  Text(
                    user?.fullName ?? "Student",

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Color.fromARGB(255, 19, 38, 52),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Student ID
                  Text(
                    "Student ID: ${user?.studentId ?? ""}",

                    style: TextStyle(
                      color: Colors.white.withOpacity(1),
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Department
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Icon(
                        Icons.school_outlined,
                        color: Color.fromARGB(255, 50, 38, 83),
                        size: 18,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        user?.department ?? "",

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Semester
                  Text(
                    "Semester: ${user?.semester ?? ""}",

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ======================================================
            // DASHBOARD CONTENT
            // ======================================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Student Activities",

                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 6, 18, 54),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Manage your courses and attendance",

                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(
                        255,
                        146,
                        117,
                        117,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // MY COURSES
                  // =================================================

                  _DashboardActionCard(
                    icon: Icons.menu_book_outlined,

                    title: "My Courses",

                    subtitle:
                        "View your enrolled courses and attendance",

                    color: Colors.blue,

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              const StudentCourseScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 13),

                  // =================================================
                  // JOIN COURSE
                  // =================================================

                  _DashboardActionCard(
                    icon: Icons.add_circle_outline,

                    title: "Join Course",

                    subtitle:
                        "Join a new course using course credentials",

                    color: Colors.indigo,

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              const JoinCourseScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 13),

                  // =================================================
                  // SCAN QR
                  // =================================================

                  _DashboardActionCard(
                    icon: Icons.qr_code_scanner,

                    title: "Scan Attendance QR",

                    subtitle:
                        "Scan the teacher's QR to mark attendance",

                    color: Colors.teal,

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              const ScanQrScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 13),

                  // =================================================
                  // ATTENDANCE HISTORY
                  // =================================================

                  _DashboardActionCard(
                    icon: Icons.history,

                    title: "Attendance History",

                    subtitle:
                        "View your complete attendance history",

                    color: Colors.deepPurple,

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              const AttendanceHistoryScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  // =================================================
                  // ACCOUNT INFORMATION
                  // =================================================

                  const Text(
                    "Account Information",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(
                        255,
                        47,
                        75,
                        114,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(18),

                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(0.05),

                          blurRadius: 10,

                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [

                        // Email
                        _InfoRow(
                          icon: Icons.email_outlined,

                          title: "Email",

                          value: user?.email ?? "",
                        ),

                        const Divider(
                          height: 25,
                        ),

                        // Student ID
                        _InfoRow(
                          icon: Icons.badge_outlined,

                          title: "Student ID",

                          value: user?.studentId ?? "",
                        ),

                        const Divider(
                          height: 25,
                        ),

                        // Department
                        _InfoRow(
                          icon: Icons.school_outlined,

                          title: "Department",

                          value: user?.department ?? "",
                        ),

                        const Divider(
                          height: 25,
                        ),

                        // Semester
                        _InfoRow(
                          icon: Icons.calendar_month_outlined,

                          title: "Semester",

                          value: user?.semester ?? "",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // =================================================
                  // LOGOUT
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.logout_sharp,
                        color: Colors.red,
                      ),

                      label: const Text(
                        "LogOut",

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(
                            255,
                            206,
                            83,
                            75,
                          ),
                        ),
                      ),

                      onPressed: () async {
                        await authProvider.logout();

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                const LoginScreen(),
                          ),

                          (_) => false,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// DASHBOARD ACTION CARD
// ===============================================================

class _DashboardActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            border: Border.all(
              color: Colors.grey.shade200,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),

                blurRadius: 8,

                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: Row(
            children: [

              // Icon
              Container(
                width: 55,
                height: 55,

                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),

                  borderRadius:
                      BorderRadius.circular(15),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      title,

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,

                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios,

                size: 17,

                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// ACCOUNT INFORMATION ROW
// ===============================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        Container(
          width: 40,
          height: 40,

          decoration: BoxDecoration(
            color: const Color.fromARGB(
              255,
              4,
              5,
              5,
            ).withOpacity(0.1),

            borderRadius:
                BorderRadius.circular(15),
          ),

          child: Icon(
            icon,
            color: Colors.blue,
            size: 22,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                title,

                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value.isEmpty
                    ? "Not Available"
                    : value,

                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}