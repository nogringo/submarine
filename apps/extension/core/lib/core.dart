import 'dart:convert';

/// A method of the core: its arguments and its result are JSON values.
typedef CoreMethod = Future<Object?> Function(Map<String, dynamic> args);

/// An error the extension can tell the user about, by its [code].
class CoreException implements Exception {
  CoreException(this.code, [this.message]);

  final String code;
  final String? message;

  @override
  String toString() => 'CoreException($code, $message)';
}

/// What the extension calls, one method at a time, in JSON.
class Core {
  Core(this._methods);

  final Map<String, CoreMethod> _methods;

  /// Runs [method] with [args], a JSON object, and answers in JSON with
  /// `{"result": ...}` or `{"error": {"code": ..., "message": ...}}`.
  Future<String> handle(String method, String args) async {
    try {
      final run = _methods[method];
      if (run == null) throw CoreException('unknownMethod', method);
      final result = await run(jsonDecode(args) as Map<String, dynamic>);
      return jsonEncode({'result': result});
    } on CoreException catch (error) {
      return _error(error.code, error.message);
    } catch (error, stack) {
      print('$method failed: $error\n$stack');
      return _error('internal', '$error');
    }
  }

  String _error(String code, String? message) => jsonEncode({
    'error': {'code': code, 'message': message},
  });
}
