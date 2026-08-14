import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _courseNameController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _departmentController = TextEditingController();

  String _selectedSemester = "1-1";

  final List<String> semesters = [
    "1-1",
    "1-2",
    "2-1",
    "2-2",
    "3-1",
    "3-2",
    "4-1",
    "4-2",
  ];
  
  //get courseProvider => null;

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
  if (!_formKey.currentState!.validate()) return;

  final courseProvider =
      Provider.of<CourseProvider>(context, listen: false);

  debugPrint("Create Course button pressed");

  final error = await courseProvider.createCourse(
    courseName: _courseNameController.text.trim(),
    courseCode: _courseCodeController.text.trim().toUpperCase(),
    department: _departmentController.text.trim(),
    semester: _selectedSemester,
  );

  debugPrint("Returned from createCourse");

  if (!mounted) return;

  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Course Created Successfully"),
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
    final courseProvider = Provider.of<CourseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Course"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _courseNameController,
                decoration: decoration("Course Name"),
                validator: (value) =>
                    value!.isEmpty ? "Enter course name" : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _courseCodeController,
                decoration: decoration("Course Code"),
                validator: (value) =>
                    value!.isEmpty ? "Enter course code" : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _departmentController,
                decoration: decoration("Department"),
                validator: (value) =>
                    value!.isEmpty ? "Enter department" : null,
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: _selectedSemester,
                decoration: decoration("Semester"),
                items: semesters.map((semester) {
                  return DropdownMenuItem(
                    value: semester,
                    child: Text(semester),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSemester = value!;
                  });
                },
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      courseProvider.isLoading ? null : _saveCourse,
                  child: courseProvider.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "CREATE COURSE",
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