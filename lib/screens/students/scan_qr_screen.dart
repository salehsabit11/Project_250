import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../providers/attendance_provider.dart';
import '../student/fingerprint_screen.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() =>
      _ScanQrScreenState();
}

class _ScanQrScreenState
    extends State<ScanQrScreen> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    final attendanceProvider =
        Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan Attendance QR",
        ),
        centerTitle: true,
      ),

      body: MobileScanner(
        onDetect: (capture) async {
          if (_isScanned) return;

          if (capture.barcodes.isEmpty) {
            return;
          }

          final barcode =
              capture.barcodes.first;

          final qrToken =
              barcode.rawValue;

          if (qrToken == null ||
              qrToken.isEmpty) {
            return;
          }

          _isScanned = true;

          /// ================================================
          /// Find session using QR TOKEN
          /// ================================================
          await attendanceProvider
              .loadSessionByQrToken(
            qrToken,
          );

          if (!mounted) return;

          final session =
              attendanceProvider.currentSession;

          /// ================================================
          /// Invalid / expired QR
          /// ================================================
          if (session == null) {
            _isScanned = false;

            ScaffoldMessenger.of(context)
                .showSnackBar(
              const SnackBar(
                content: Text(
                  "QR code is invalid or expired.",
                ),
              ),
            );

            return;
          }

          /// ================================================
          /// Valid QR
          /// ================================================
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const FingerprintScreen(),
            ),
          );
        },
      ),
    );
  }
}