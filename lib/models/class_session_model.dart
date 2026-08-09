class ClassSessionModel {
  final String sessionId;

  final int classNumber;

  final DateTime classDate;

  final int totalPresent;

  const ClassSessionModel({
    required this.sessionId,
    required this.classNumber,
    required this.classDate,
    required this.totalPresent,
  });
}