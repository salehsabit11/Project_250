import 'package:attendence_app1/screens/students/student_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

import '../teacher/teacher_dashboard.dart';
import 'login_form.dart';
import 'register_screen.dart';
import 'verify_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ==========================================================
  // FORM
  // ==========================================================

  final _formKey = GlobalKey<FormState>();

  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  // ==========================================================
  // PASSWORD VISIBILITY
  // ==========================================================

  bool _obscurePassword = true;

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<void> _login() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Firebase login
    final error = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    // ========================================================
    // LOGIN ERROR
    // ========================================================

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
      );

      return;
    }

    // ========================================================
    // RELOAD FIREBASE USER
    // ========================================================

    await AuthService.reloadUser();

    if (!mounted) return;

    // ========================================================
    // EMAIL VERIFICATION
    // ========================================================

    if (!AuthService.isEmailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
      );

      return;
    }

    // ========================================================
    // GET CURRENT USER
    // ========================================================

    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User data not found."),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    // ========================================================
    // TEACHER
    // ========================================================

    if (user.role == "teacher") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TeacherDashboard()),
      );

      return;
    }

    // ========================================================
    // STUDENT
    // ========================================================

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const StudentDashboard()),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          // ====================================================
          // BACKGROUND
          // ====================================================

          // ====================================================
          // BACKGROUND IMAGE
          // ====================================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,

            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.999994,

              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
          // ====================================================
          // DARK OVERLAY
          // ====================================================
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.38)),
          ),

          // ====================================================
          // DARK OVERLAY
          // ====================================================
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.42)),
          ),

          // ====================================================
          // LOGIN CONTENT
          // ====================================================
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 108,
                ),

                child: LoginForm(
                  formKey: _formKey,

                  emailController: _emailController,

                  passwordController: _passwordController,

                  obscurePassword: _obscurePassword,

                  isLoading: Provider.of<AuthProvider>(context).isLoading,

                  // Password visibility
                  onTogglePassword: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },

                  // Login
                  onLogin: _login,

                  // Register
                  onRegister: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },

                  // Forgot password
                  onForgotPassword: () {
                    // Implement Forgot Password Screen
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
