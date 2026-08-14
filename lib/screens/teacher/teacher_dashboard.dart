import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'create_course_screen.dart';
import 'course_list_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 214, 228, 228),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 45, 116, 160),
        foregroundColor: const Color.fromARGB(26, 145, 49, 49),
        centerTitle: true,
        title: const Text(
          "Teacher Dashboard",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Color.fromARGB(255, 6, 26, 74),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 30),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 65, 115, 165),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
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
                      child: Icon(Icons.person, size: 48, color: Colors.blue),
                    ),
                  ),
                  // teacher name
                  const SizedBox(height: 15),
                  Text(
                    user?.fullName ?? "Teacher",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 19, 38, 52),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  //designation
                  Text(
                    user?.designation ?? "Teacher",
                    style: TextStyle(
                      color: Colors.white.withOpacity(1),
                      fontSize: 18,
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
                ],
              ),
            ),

            const SizedBox(height: 8),

            //dashboard content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage Courses',
                    //textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 6, 18, 54),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Create and manage your university courses",
                    style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 146, 117, 117)),
                  ),
                  const SizedBox(height: 18),

                  // create courses
                  _DashboardActionCard(
                    icon: Icons.add_circle_outline,
                    title: "Create Course",
                    subtitle: "Create a new course for your students",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateCourseScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 13),

                  //my course
                  _DashboardActionCard(
                    icon: Icons.add_circle_outline,
                    title: "My Course",
                    subtitle: "View and manage courses for your students",
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CourseListScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  //additional information
                  const Text(
                    "Account Information",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 47, 75, 114),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          icon: Icons.email_outlined,
                          title: "Email",
                          value: user?.email ?? "",
                        ),

                        const Divider(height: 25),

                        _infoRow(
                          icon: Icons.school_outlined,
                          title: "Department",
                          value: user?.department ?? "",
                        ),
                        const Divider(height: 25),

                        _infoRow(
                          icon: Icons.badge_outlined,
                          title: "Designation",
                          value: user?.designation ?? "",
                        ),
                        const Divider(height: 25),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),

                  //logout
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout_sharp, color: Colors.red),
                      label: const Text(
                        "LogOut",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 206, 83, 75),
                        ),
                      ),
                      // style: ElevatedButton.styleFrom(
                      //     backgroundColor:
                      //         const Color.fromARGB(255, 164, 163, 163),
                      //     foregroundColor: Colors.white,

                      //     elevation: 0,

                      //     shape: RoundedRectangleBorder(
                      //       borderRadius:
                      //           BorderRadius.circular(15),
                      //     ),
                      //   ),
                      

                      onPressed: () async {
                        await authProvider.logout();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (_) => false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            border: Border.all(color: Colors.grey.shade200),
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
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Icon(icon, color: color, size: 30),
              ),

              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

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
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
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

// information row
class _infoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _infoRow({
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
            color: const Color.fromARGB(255, 4, 5, 5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Colors.blue, size: 22),
        ),
        const SizedBox(width: 14,),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 3,),

              Text(
                value.isEmpty?"Not Avialabele":value,
                style: const TextStyle(
                  fontSize: 15,
                 // fontWeight: FontWeight.bold,
                ),
              )
          ],
        ))
      ],
    );
  }
}
