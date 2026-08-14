import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController emailController;
  final TextEditingController passwordController;

  final bool obscurePassword;
  final bool isLoading;

  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onLogin,
    required this.onRegister,
    required this.onForgotPassword,
  });

  // ==========================================================
  // INPUT FIELD
  // ==========================================================

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,

      style: const TextStyle(
        color: Color.fromARGB(221, 16, 6, 6),
        fontSize: 15,
      ),

      cursorColor: const Color(0xFF0878F9),

      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.90),

        hintText: hint,

        hintStyle: const TextStyle(
          color: Colors.black45,
          fontSize: 15,
        ),

        // Blue icon
        prefixIcon: Container(
          width: 34,
          height: 34,
          margin: const EdgeInsets.all(7),

          decoration: BoxDecoration(
            color: const Color(0xFF0878F9),
            borderRadius: BorderRadius.circular(8),
          ),

          child: Icon(
            icon,
            color: Colors.white,
            size: 19,
          ),
        ),

        suffixIcon: suffixIcon,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF0878F9),
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),

        errorStyle: const TextStyle(
          color: Colors.orangeAccent,
          fontSize: 10,
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      // Don't let the card become too wide
      constraints: const BoxConstraints(
        maxWidth: 390,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 18,
      ),

      decoration: BoxDecoration(
        // Glass background
        color: Colors.black.withOpacity(0.33),

        borderRadius: BorderRadius.circular(28),

        border: Border.all(
          color: Colors.white.withOpacity(0.65),
          width: 1.2,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.18),
            blurRadius: 14,
            spreadRadius: 1,
          ),

          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Form(
        key: formKey,

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            // ==================================================
            // LOGIN TITLE
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1.5,
                    color: Colors.blueAccent,
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                  ),

                  child: Text(
                    "Login",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    height: 1.5,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ==================================================
            // SCHOOL ICON
            // ==================================================

            Container(
              height: 58,
              width: 70,

              // decoration: BoxDecoration(
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.blueAccent.withOpacity(0.35),
              //       blurRadius: 18,
              //       spreadRadius: 1,
              //     ),
              //   ],
              // ),

              // child: const Icon(
              //   Icons.school,
              //   color: Color.fromARGB(255, 121, 151, 184),
              //   size: 58,
              // ),
            ),

            const SizedBox(height: 0),

            // ==================================================
            // APP TITLE
            // ==================================================

            const Text(
              "University Attendance",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // EMAIL
            // ==================================================

            _inputField(
              controller: emailController,
              hint: "Email",
              icon: Icons.email,

              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return "Enter your email";
                }

                return null;
              },
            ),

            const SizedBox(height: 10),

            // ==================================================
            // PASSWORD
            // ==================================================

            _inputField(
              controller: passwordController,
              hint: "Password",
              icon: Icons.lock,
              obscureText: obscurePassword,

              suffixIcon: IconButton(
                onPressed: onTogglePassword,

                padding: EdgeInsets.zero,

                icon: Icon(
                  obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off,

                  color: Colors.black54,
                  size: 22,
                ),
              ),

              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return "Enter your password";
                }

                if (value.length < 6) {
                  return "Password must be at least 6 characters";
                }

                return null;
              },
            ),

            const SizedBox(height: 15),

            // ==================================================
            // LOGIN BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 48,

              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : onLogin,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF0878F9),

                  disabledBackgroundColor:
                      Colors.blue.withOpacity(0.5),

                  elevation: 6,

                  shadowColor:
                      Colors.blueAccent.withOpacity(0.5),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                ),

                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,

                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "LOGIN",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 5),

            // ==================================================
            // FORGOT PASSWORD
            // ==================================================

            TextButton(
              onPressed: onForgotPassword,

              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 8,
                ),
                tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
              ),

              child: const Text(
                "Forgot Password?",

                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 5),

            // ==================================================
            // REGISTER
            // ==================================================

            Wrap(
              alignment: WrapAlignment.center,

              crossAxisAlignment:
                  WrapCrossAlignment.center,

              children: [
                const Text(
                  "Don't have an account?",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),

                TextButton(
                  onPressed: onRegister,

                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                  ),

                  child: const Text(
                    "Register",

                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}