import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../providers/attendance_provider.dart';
import '../student/fingerprint_screen.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Attendance QR"),
      ),
      body: MobileScanner(
        onDetect: (capture) async {
          if (_isScanned) return;

          final barcode = capture.barcodes.first;

          final sessionId = barcode.rawValue;

          if (sessionId == null) return;

          _isScanned = true;

          await attendanceProvider.loadSession(sessionId);

          if (!mounted) return;

          final session = attendanceProvider.currentSession;

          if (session == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Invalid QR Code"),
              ),
            );

            Navigator.pop(context);
            return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const FingerprintScreen(),
            ),
          );
        },
      ),
    );
  }
}