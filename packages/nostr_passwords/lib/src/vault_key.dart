import 'package:ndk/ndk.dart';

final _hexKey = RegExp(r'^[0-9a-f]{64}$');

/// The private key, in hex, of a vault key written as an nsec or in hex.
/// Returns null for anything else, an npub included.
String? parseVaultKey(String text) {
  final value = text.trim().toLowerCase();
  // Nip19.decode decodes an npub too, and returns '' when it fails.
  final key = value.startsWith('nsec1') ? Nip19.decode(value) : value;
  return _hexKey.hasMatch(key) ? key : null;
}
