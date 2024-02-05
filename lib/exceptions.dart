class ExamAppException implements Exception {
  String message;

  ExamAppException(this.message);

  @override
  String toString() {
    return message;
  }
}