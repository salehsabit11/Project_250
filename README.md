Smart Attendance System

<p align="center">
  <strong>Project 250 — University Attendance</strong><br>
  Dynamic QR-Based Attendance Management System
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black" alt="Firebase">
  <img src="https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Project-250-success" alt="Project 250">
</p>

📌 Overview

University Attendance is a digital attendance management system developed for Project 250. It is designed to make classroom attendance faster, easier, and more secure by replacing traditional manual attendance with a dynamic QR-code-based attendance system.

The system has two primary user roles:

👨‍🏫 Teacher

👨‍🎓 Student

Teachers create and manage their courses. Each course has a course code that students use to enroll in the correct class. During class, the teacher starts an attendance session and displays a dynamically generated QR code using the web/desktop interface and classroom projector.

Students who are enrolled in that course scan the QR code using their phones. The QR code is automatically regenerated every 10 seconds, making previously captured QR codes invalid and helping reduce proxy attendance.

✨ Key Features

👨‍🏫 Teacher Features

Teacher registration and authentication

Teacher dashboard

Create and manage courses

Generate course codes

View assigned courses

Start a live attendance session

Generate dynamic attendance QR codes

Automatically refresh QR code every 10 seconds

Display QR code on desktop/web interface for classroom projection

Monitor attendance during an active session

End/terminate an attendance session

View course attendance history

View attendance by class/session

Export attendance reports as CSV

Export attendance reports as PDF

👨‍🎓 Student Features

Student registration and authentication

Student dashboard

Join courses using course code and teacher information

View enrolled courses

Scan live attendance QR codes

Real-time attendance submission

View personal attendance history

Account management and logout

🔄 How It Works

The basic classroom workflow is:

                 ┌──────────────────────┐
                 │       Teacher        │
                 │       Login          │
                 └──────────┬───────────┘
                            │
                            ▼
                 ┌──────────────────────┐
                 │    Select Course     │
                 │   / Create Course    │
                 └──────────┬───────────┘
                            │
                            ▼
                 ┌──────────────────────┐
                 │ Start Attendance     │
                 │      Session         │
                 └──────────┬───────────┘
                            │
                            ▼
                 ┌──────────────────────┐
                 │   Dynamic QR Code    │
                 │  Refreshes / 10 sec  │
                 └──────────┬───────────┘
                            │
                            ▼
                     ┌─────────────┐
                     │  Projector  │
                     └──────┬──────┘
                            │
              ┌─────────────┴─────────────┐
              │                           │
              ▼                           ▼
       ┌──────────────┐           ┌──────────────┐
       │   Student 1  │           │   Student 2  │
       │   Scan QR    │    ...    │   Scan QR    │
       └──────┬───────┘           └──────┬───────┘
              │                          │
              └─────────────┬────────────┘
                            ▼
                 ┌──────────────────────┐
                 │ Validate Student +   │
                 │ Course + QR Session  │
                 └──────────┬───────────┘
                            │
                            ▼
                 ┌──────────────────────┐
                 │ Attendance Recorded  │
                 └──────────────────────┘

🔐 Dynamic QR Attendance

The main security feature of the system is the dynamic QR code.

Instead of displaying one QR code throughout the entire class, the system continuously replaces the active QR code.

QR Lifecycle

Teacher selects the course.

Teacher starts an attendance session.

The system generates an active QR code.

Teacher displays the QR code through the desktop/web interface.

The QR code is projected in the classroom.

Students scan the currently displayed QR code.

The system validates the student and course enrollment.

Attendance is recorded.

After 10 seconds, a new QR code is generated.

The previous QR code becomes invalid.

The process continues until the teacher ends the session.

Why Dynamic QR?

A static QR code could easily be photographed and shared with another person. By regenerating the QR code every 10 seconds, an old screenshot becomes unusable after the active code changes.

The dynamic QR mechanism works together with:

Student authentication

Course enrollment validation

Teacher/course association

Active-session validation

Duplicate attendance prevention

🎓 Course Enrollment

Students must be enrolled in a course before they can receive attendance for it.

Enrollment Flow

Teacher
   │
   ├── Creates Course
   │
   └── Course Code
          │
          ▼
Student ──┤
          │
          ├── Enters Course Code
          ├── Provides Teacher Information
          │
          ▼
      Course Validation
          │
          ▼
       Enrollment

Only students who are successfully enrolled in the selected course should be allowed to submit attendance for that course.

👥 User Roles

Role

Responsibilities

Teacher

Create courses, manage courses, start attendance sessions, display QR codes, monitor attendance, view reports, export records

Student

Register/login, join courses, scan attendance QR codes, view attendance history

🖥️ Teacher Interface

The teacher workflow is centered around classroom control.

Teacher Dashboard

The teacher dashboard provides access to:

Profile/account information

Course management

Assigned courses

Attendance sessions

Attendance reports

Course Management

Teachers can create courses and use the generated course information to allow students to enroll.

Live Attendance Screen

The live attendance screen is designed to be opened on a desktop/laptop and displayed through a classroom projector.

It provides:

Current QR code

QR refresh status/timer

Active attendance session

Attendance progress

Session termination control

Attendance Report

Teachers can review attendance for a course and export records in:

CSV format

PDF format

📱 Student Interface

The student interface focuses on quick attendance submission.

Student Dashboard

Students can access:

Enrolled courses

QR scanner

Attendance history

Account controls

QR Scanner

During an active class:

Student opens the scanner.

Student points the phone camera at the projected QR code.

System reads the QR.

System verifies the student.

System verifies course enrollment.

System verifies the active QR/session.

Attendance is recorded.

Attendance History

Students can view their previous attendance records for their enrolled courses.

🛡️ Anti-Proxy Attendance

University Attendance is designed to reduce proxy attendance using multiple validation layers.

Security Layer

Purpose

Student authentication

Identifies the student submitting attendance

Course enrollment

Ensures the student belongs to the course

Teacher-course association

Connects the attendance session to the correct teacher

Dynamic QR

Makes old QR screenshots quickly invalid

10-second refresh

Frequently changes the active attendance token

Active session validation

Prevents attendance outside an active class session

Duplicate prevention

Prevents multiple attendance submissions for one session

Note: Dynamic QR codes significantly reduce proxy opportunities, but no single mechanism can guarantee complete prevention of proxy attendance in every real-world situation.

📊 Attendance Reports

Teachers can access attendance records for their courses.

A report may contain information such as:

Student name

Student ID/registration number

Course

Attendance date

Attendance time

Attendance status

Class/session information

Reports can be exported as:

CSV

Useful for:

Excel/Google Sheets

Data analysis

Record keeping

Further processing

PDF

Useful for:

Printing

Formal submission

Human-readable attendance records

Archiving

🏗️ Project Architecture

The repository is a Flutter application with Firebase services and separates the application into areas such as models, providers, screens, services, constants and theme configuration.

Project_250/
│
├── android/
├── web/
├── windows/
├── assets/
│   └── images/
│
├── lib/
│   ├── constants/
│   ├── models/
│   ├── providers/
│   ├── screens/
│   ├── services/
│   ├── theme/
│   ├── firebase_options.dart
│   └── main.dart
│
├── test/
├── firebase.json
├── pubspec.yaml
├── pubspec.lock
└── README.md

🛠️ Technology Stack

The current repository is built with:

Frontend / Application

Flutter

Dart

Material Design

Backend / Cloud

Firebase Authentication

Cloud Firestore

Firebase Storage

State Management

Provider

QR Code

qr_flutter — QR code generation

mobile_scanner — QR code scanning

Authentication & Utilities

local_auth — biometric authentication support

intl — date/time formatting

uuid — unique identifiers

fluttertoast — user notifications

Report & File Handling

pdf — PDF generation

printing — PDF printing/sharing

csv — CSV generation

path_provider — local file paths

share_plus — file sharing

The dependency configuration in the repository identifies Flutter/Dart, Firebase services, Provider, QR libraries, biometric authentication, and CSV/PDF export packages. citeturn1view0

🚀 Getting Started

Prerequisites

Make sure the following are installed:

Flutter SDK

Dart SDK compatible with the project's Flutter version

Android Studio or VS Code

Android emulator or physical Android device

Firebase project/configuration

The repository currently uses Dart SDK ^3.11.5 in pubspec.yaml. citeturn1view0

1. Clone the Repository

git clone https://github.com/salehsabit11/Project_250.git
cd Project_250

2. Install Dependencies

flutter pub get

3. Check Flutter Setup

flutter doctor

Resolve any required Android, Flutter or device configuration issues reported by flutter doctor.

4. Configure Firebase

The project contains Firebase configuration files and uses:

Firebase Authentication

Cloud Firestore

Firebase Storage

Make sure the Firebase project is correctly configured for the target platforms before running the application.

5. Run the Application

For a connected device:

flutter run

To see available devices:

flutter devices

For web development, use a supported browser/device listed by Flutter and run:

flutter run -d chrome

🧪 Testing

Run the Flutter test suite with:

flutter test

For static analysis:

flutter analyze

📦 Build

Android APK

flutter build apk

Android App Bundle

flutter build appbundle

Web

flutter build web

🔄 Typical Attendance Session

A complete attendance session looks like this:

Teacher Login
     ↓
Teacher Dashboard
     ↓
Select Course
     ↓
Start Attendance
     ↓
Generate QR
     ↓
Display QR on Projector
     ↓
Student Opens Scanner
     ↓
Student Scans QR
     ↓
Validate:
  ├─ Student Account
  ├─ Course Enrollment
  ├─ Teacher/Course
  ├─ Active Session
  └─ Current QR
     ↓
Attendance Recorded
     ↓
QR Changes Every 10 Seconds
     ↓
Students Continue Scanning
     ↓
Teacher Ends Session
     ↓
Attendance Report
     ↓
CSV / PDF Export

📋 Functional Requirements

Teacher authentication

Student authentication

Course creation

Course enrollment

Dynamic QR attendance

QR scanning

Attendance history

Teacher attendance reports

CSV export

PDF export

Classroom projector workflow

Short-lived QR validation

The checklist describes the intended/current project feature set; exact implementation status may change as development continues.

🔮 Future Improvements

Possible future improvements include:

Attendance percentage calculation

Course-wise attendance analytics

Low-attendance alerts

Date-range report filtering

Scheduled attendance sessions

Better offline/retry handling

Attendance statistics and charts

Advanced anti-proxy mechanisms

Institutional administrator panel

Audit logs

Notifications for students and teachers

📚 Project Documentation

A detailed project documentation can cover:

System overview

User roles

Interface descriptions

System workflow

Dynamic QR mechanism

Course enrollment

Attendance validation

Security considerations

Data model

Functional requirements

Non-functional requirements

Future improvements

🤝 Contribution

This project is being developed as part of Project 250.

To contribute:

Fork the repository.

Create a feature branch.

git checkout -b feature/your-feature

Make your changes.

Test the application.

flutter analyze
flutter test

Commit your changes.

git add .
git commit -m "Add: your feature"

Push your branch.

git push origin feature/your-feature

Open a Pull Request.

For team members working directly on the repository, coordinate changes with the project team before merging major features.

👨‍💻 Project

Project Name: University Attendance
Course: Project 250
Repository: salehsabit11/Project_250
Application: Dynamic QR-Based Attendance Management System

📄 License

This project is developed for academic purposes as part of Project 250.

If this project is later released for public use, an appropriate open-source license can be added here.

<p align="center">
  Made with Flutter & Firebase for Project 250
</p>
