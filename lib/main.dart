import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'providers/enrollment_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';
import 'providers/attendance_provider.dart';
import 'providers/attendance_record_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => CourseProvider()),

        ChangeNotifierProvider(create: (_) => EnrollmentProvider()),

        ChangeNotifierProvider(create: (_) => AttendanceProvider()),

        ChangeNotifierProvider(create: (_) => AttendanceRecordProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'University Attendance',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
