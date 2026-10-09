/// The nostr-mail bridge a client gives new email addresses by default.
const defaultMailBridge = 'uid.ovh';

final _domain = RegExp(
  r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$',
);

/// A bridge's domain as a user types it, in lowercase, an @ before it
/// allowed. Returns null for anything else, a host without a dot included.
String? parseMailBridge(String text) {
  final trimmed = text.trim().toLowerCase();
  final domain = trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
  return _domain.hasMatch(domain) ? domain : null;
}
