import 'package:nostr_passwords/nostr_passwords.dart';

import 'core.dart';

/// The items of the Bitwarden JSON export [source], in Bitwarden's JSON, as
/// the app imports them, once [password] opens it if it is password
/// protected.
Future<List<Map<String, dynamic>>> openExport(
  String source,
  String? password,
) async {
  try {
    final export = password == null
        ? source
        : await decryptBitwardenExport(source, password);
    return [for (final cipher in parseBitwardenExport(export)) cipher.toJson()];
  } on PasswordProtectedExportException {
    throw CoreException('passwordProtectedExport');
  } on EncryptedExportException {
    throw CoreException('encryptedExport');
  } on WrongExportPasswordException {
    throw CoreException('wrongExportPassword');
  } on FormatException {
    throw CoreException('notBitwardenExport');
  }
}
