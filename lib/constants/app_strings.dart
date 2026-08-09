/// All application text is stored here.
///
/// This makes it easier to:
/// - Update text
/// - Maintain consistency
/// - Add localization in the future
class AppStrings {
  AppStrings._();

  // ==========================
  // App
  // ==========================

  static const String appName = "University Attendance";

  // ==========================
  // Authentication
  // ==========================

  static const String login = "Login";
  static const String register = "Register";
  static const String logout = "Logout";

  static const String email = "Email";
  static const String password = "Password";
  static const String confirmPassword = "Confirm Password";

  static const String forgotPassword = "Forgot Password?";
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = "Already have an account?";

  // ==========================
  // User Information
  // ==========================

  static const String fullName = "Full Name";
  static const String studentId = "Student ID";
  static const String teacherId = "Teacher ID";

  static const String department = "Department";
  static const String semester = "Semester";

  // ==========================
  // Roles
  // ==========================

  static const String teacher = "Teacher";
  static const String student = "Student";

  // ==========================
  // Teacher
  // ==========================

  static const String createCourse = "Create Course";
  static const String myCourses = "My Courses";
  static const String generateQr = "Generate QR";
  static const String attendanceHistory = "Attendance History";

  // ==========================
  // Student
  // ==========================

  static const String joinCourse = "Join Course";
  static const String scanQr = "Scan QR";
  static const String myAttendance = "My Attendance";
  static const String attendancePercentage = "Attendance Percentage";

  // ==========================
  // Profile
  // ==========================

  static const String profile = "Profile";
  static const String editProfile = "Edit Profile";

  // ==========================
  // Buttons
  // ==========================

  static const String save = "Save";
  static const String cancel = "Cancel";
  static const String continueText = "Continue";
  static const String submit = "Submit";

  // ==========================
  // Attendance
  // ==========================

  static const String present = "Present";
  static const String absent = "Absent";
  static const String late = "Late";

  // ==========================
  // Messages
  // ==========================

  static const String loading = "Loading...";
  static const String noData = "No data available";
  static const String somethingWentWrong =
      "Something went wrong. Please try again.";
}