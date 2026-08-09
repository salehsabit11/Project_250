import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController _departmentController = TextEditingController();

  final TextEditingController _studentIdController = TextEditingController();

  final TextEditingController _teacherIdController = TextEditingController();

  final TextEditingController _semesterController = TextEditingController();

  final TextEditingController _designationController = TextEditingController();

  final TextEditingController _teacherCodeController = TextEditingController();

  bool _isTeacher = false;

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _departmentController.dispose();
    _studentIdController.dispose();
    _teacherIdController.dispose();
    _semesterController.dispose();
    _designationController.dispose();
    _teacherCodeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check teacher code
    if (_isTeacher) {
      try {
        final teacherCode = await AuthService.getTeacherCode();

        if (_teacherCodeController.text.trim() != teacherCode.trim()) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid Teacher Secret Code")),
          );
          return;
        }
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
        return;
      }
    }

    final error = await authProvider.register(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _isTeacher ? "teacher" : "student",
      department: _departmentController.text.trim(),
      studentId: _isTeacher ? null : _studentIdController.text.trim(),
      teacherId: _isTeacher ? _teacherIdController.text.trim() : null,
      semester: _isTeacher ? null : _semesterController.text.trim(),
      designation: _isTeacher ? _designationController.text.trim() : null,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Registration successful. Please verify your email."),
      ),
    );

    Navigator.pop(context);
  }

  InputDecoration decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget roleCard({
    required bool teacher,
    required IconData icon,
    required String title,
  }) {
    final selected = _isTeacher == teacher;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isTeacher = teacher;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected ? Colors.blue.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? Colors.blue : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 45, color: Colors.blue),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);



    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),

                const Text(
                  "Register As",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    roleCard(
                      teacher: false,
                      icon: Icons.school,
                      title: "Student",
                    ),

                    const SizedBox(width: 15),

                    roleCard(
                      teacher: true,
                      icon: Icons.person,
                      title: "Teacher",
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: _fullNameController,
                  decoration: decoration("Full Name", Icons.person),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter Full Name";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: _emailController,
                  decoration: decoration("Email", Icons.email),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter Email";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: _departmentController,
                  decoration: decoration("Department", Icons.apartment),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter Department";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                if (_isTeacher == false)
                  TextFormField(
                    controller: _studentIdController,
                    decoration: decoration("Student ID", Icons.badge),
                    validator: (value) {
                      if (!_isTeacher && (value == null || value.isEmpty)) {
                        return "Enter Student ID";
                      }
                      return null;
                    },
                  ),

                if (_isTeacher)
                  TextFormField(
                    controller: _teacherIdController,
                    decoration: decoration("Teacher ID", Icons.badge),
                    validator: (value) {
                      if (_isTeacher && (value == null || value.isEmpty)) {
                        return "Enter Teacher ID";
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 15),

                if (!_isTeacher)
                  TextFormField(
                    controller: _semesterController,
                    decoration: decoration("Semester", Icons.class_),
                    validator: (value) {
                      if (!_isTeacher && (value == null || value.isEmpty)) {
                        return "Enter Semester";
                      }
                      return null;
                    },
                  ),

                if (_isTeacher)
                  TextFormField(
                    controller: _designationController,
                    decoration: decoration("Designation", Icons.work),
                    validator: (value) {
                      if (_isTeacher && (value == null || value.isEmpty)) {
                        return "Enter Designation";
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 15),

                if (_isTeacher)
                  TextFormField(
                    controller: _teacherCodeController,
                    decoration: decoration(
                      "Teacher Secret Code",
                      Icons.lock_outline,
                    ),
                    validator: (value) {
                      if (_isTeacher && (value == null || value.isEmpty)) {
                        return "Enter Teacher Secret Code";
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                      icon: Icon(
                        _hidePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "Minimum 6 characters";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _hideConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _hideConfirmPassword = !_hideConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _hideConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _register,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "REGISTER",
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Already have an account? Login"),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
