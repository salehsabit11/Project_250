import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/course_model.dart';
import '../../providers/attendance_provider.dart';

class GenerateQrScreen extends StatefulWidget {
  final CourseModel course;

  const GenerateQrScreen({
    super.key,
    required this.course,
  });

  @override
  State<GenerateQrScreen> createState() =>
      _GenerateQrScreenState();
}

class _GenerateQrScreenState
    extends State<GenerateQrScreen> {
  int _secondsLeft = 10;

  Timer? _timer;

  bool _isRegenerating = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAttendance();
    });
  }

  /// ==========================================================
  /// Start NEW Class
  /// ==========================================================
  Future<void> _startAttendance() async {
    final provider =
        Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    final error =
        await provider.startAttendance(
      courseId: widget.course.id,
      courseName: widget.course.courseName,
      courseCode: widget.course.courseCode,
    );

    if (error != null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );

      Navigator.pop(context);

      return;
    }

    _startTimer();
  }

  /// ==========================================================
  /// Start 10 Second QR Timer
  /// ==========================================================
  void _startTimer() {
    _timer?.cancel();

    _secondsLeft = 10;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsLeft <= 1) {
          setState(() {
            _secondsLeft = 0;
            _isRegenerating = true;
          });

          timer.cancel();

          await _regenerateQr();

          if (!mounted) return;

          setState(() {
            _secondsLeft = 10;
            _isRegenerating = false;
          });

          _startTimer();

          return;
        }

        setState(() {
          _secondsLeft--;
        });
      },
    );
  }

  /// ==========================================================
  /// Generate NEW QR
  ///
  /// IMPORTANT:
  /// This DOES NOT create a new class.
  /// ==========================================================
  Future<void> _regenerateQr() async {
    final provider =
        Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    final error =
        await provider.regenerateQr();

    if (error != null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
    }
  }

  /// ==========================================================
  /// End Class
  /// ==========================================================
  Future<void> _endAttendance() async {
    _timer?.cancel();

    final provider =
        Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    final error =
        await provider.stopAttendance();

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Class attendance session ended.",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider =
        Provider.of<AttendanceProvider>(
      context,
    );

    final session =
        attendanceProvider.currentSession;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate QR"),
        centerTitle: true,
      ),

      body: session == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  /// ==================================================
                  /// Course Name
                  /// ==================================================
                  Text(
                    widget.course.courseName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// ==================================================
                  /// Course Code
                  /// ==================================================
                  Text(
                    widget.course.courseCode,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// ==================================================
                  /// CLASS NUMBER
                  /// ==================================================
                  Text(
                    "Class ${session.classNumber}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// ==================================================
                  /// QR CODE
                  /// ==================================================
                  AnimatedSwitcher(
                    duration:
                        const Duration(milliseconds: 300),

                    child: _isRegenerating
                        ? const SizedBox(
                            key: ValueKey("loading"),
                            height: 250,
                            width: 250,
                            child: Center(
                              child:
                                  CircularProgressIndicator(),
                            ),
                          )
                        : Container(
                            key: ValueKey(
                              session.qrToken,
                            ),
                            padding:
                                const EdgeInsets.all(12),

                            decoration:
                                BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 10,
                                  color: Colors.black
                                      .withOpacity(0.15),
                                ),
                              ],
                            ),

                            child: QrImageView(
                              data: session.qrToken,
                              version: QrVersions.auto,
                              size: 250,
                            ),
                          ),
                  ),

                  const SizedBox(height: 25),

                  /// ==================================================
                  /// TIMER
                  /// ==================================================
                  Text(
                    _isRegenerating
                        ? "Generating new QR..."
                        : "QR changes in $_secondsLeft seconds",
                    style: TextStyle(
                      fontSize: 20,
                      color: _secondsLeft <= 3
                          ? Colors.red
                          : Colors.green,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Students must scan the current QR before it expires.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const Spacer(),

                  /// ==================================================
                  /// END CLASS BUTTON
                  /// ==================================================
                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed:
                          attendanceProvider.isLoading
                              ? null
                              : _endAttendance,

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),

                      child:
                          attendanceProvider.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child:
                                      CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "End Class",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}