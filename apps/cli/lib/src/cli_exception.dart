/// A failure to report to the user as is, without a stack trace.
class CliException implements Exception {
  CliException(this.message);

  final String message;

  @override
  String toString() => message;
}
