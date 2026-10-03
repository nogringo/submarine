import 'package:unorm_dart/unorm_dart.dart' as unorm;

import 'cipher/cipher.dart';
import 'cipher/login.dart';
import 'item.dart';

/// Bitwarden's basic search: every word of [query] is found, ignoring case and
/// accents, in the name, the [Cipher.subtitle], a login's hostnames or the
/// notes, or starts the id.
List<Item> searchItems(Iterable<Item> items, String query) {
  final terms = _normalize(query.trim().toLowerCase())
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty);
  return [
    for (final item in items)
      if (terms.every((term) => _matches(item, term))) item,
  ];
}

bool _matches(Item item, String term) {
  bool contains(String? text) =>
      text != null && _normalize(text.toLowerCase()).contains(term);

  final cipher = item.cipher;
  final uris = cipher.type == CipherType.login
      ? cipher.login?.uris ?? const <LoginUri>[]
      : const <LoginUri>[];
  return contains(cipher.name) ||
      (term.length >= 8 && item.id.startsWith(term)) ||
      contains(cipher.subtitle) ||
      uris.any((uri) => contains(_hostname(uri))) ||
      contains(cipher.notes);
}

/// The hostname Bitwarden searches a login URI by, none for a regex.
String? _hostname(LoginUri uri) {
  final value = uri.uri?.trim() ?? '';
  if (value.isEmpty ||
      uri.match == UriMatchStrategy.regularExpression ||
      value.startsWith(RegExp('data:|about:|file:'))) {
    return null;
  }
  final url = value.contains('://') ? value : 'http://$value';
  final host = Uri.tryParse(url)?.host ?? '';
  return host.isEmpty ? null : host;
}

/// Drops accents, as Bitwarden does: "Société" is found by "societe".
String _normalize(String text) =>
    unorm.nfd(text).replaceAll(RegExp('[̀-ͯ]'), '');
