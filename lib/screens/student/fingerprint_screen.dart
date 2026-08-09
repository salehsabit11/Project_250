import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../providers/attendance_provider.dart';
import '../../providers/attendance_record_provider.dart';

class FingerprintScreen extends StatefulWidget {
  const FingerprintScreen({super.key});

  @override
  State<FingerprintScreen> createState() =>
      _FingerprintScreenState();
}

class _FingerprintScreenState
    extends State<FingerprintScreen> {
  final LocalAuthentication _auth = LocalAuthentication();

  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    _isAuthenticating = true;

    try {
      final authenticated =
          await _auth.authenticate(
        localizedReason:
            "Authenticate to mark attendance",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!mounted) return;

      if (!authenticated) {
        Navigator.pop(context);
        return;
      }

      final attendanceProvider =
          Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );

      final recordProvider =
          Provider.of<AttendanceRecordProvider>(
        context,
        listen: false,
      );

      final session =
          attendanceProvider.currentSession;

      if (session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Attendance session not found."),
          ),
        );

        Navigator.pop(context);
        return;
      }

      final error =
          await recordProvider.markAttendance(
        session: session,
      );

      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );

        Navigator.pop(context);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Attendance marked successfully!",
          ),
        ),
      );

      Navigator.popUntil(
        context,
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}