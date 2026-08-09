import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/enrollment_provider.dart';

class JoinCourseScreen extends StatefulWidget {
  const JoinCourseScreen({super.key});

  @override
  State<JoinCourseScreen> createState() => _JoinCourseScreenState();
}

class _JoinCourseScreenState extends State<JoinCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _courseCodeController = TextEditingController();
  final _teacherCodeController = TextEditingController();

  @override
  void dispose() {
    _courseCodeController.dispose();
    _teacherCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinCourse() async {
    if (!_formKey.currentState!.validate()) return;

    final enrollmentProvider =
        Provider.of<EnrollmentProvider>(context, listen: false);

    final error = await enrollmentProvider.joinCourse(
      courseCode: _courseCodeController.text.trim().toUpperCase(),
      teacherCode: _teacherCodeController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Course Joined Successfully"),
      ),
    );

    Navigator.pop(context);
  }

  InputDecoration decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enrollmentProvider =
        Provider.of<EnrollmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Join Course"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: _courseCodeController,
                decoration: decoration("Course Code"),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Enter Course Code"
                        : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _teacherCodeController,
                decoration: decoration("Teacher ID"),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Enter Teacher ID"
                        : null,
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: enrollmentProvider.isLoading
                      ? null
                      : _joinCourse,
                  child: enrollmentProvider.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "JOIN COURSE",
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}