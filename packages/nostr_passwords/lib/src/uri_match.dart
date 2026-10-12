import 'package:punycoder/punycoder.dart';

import 'cipher/cipher.dart';
import 'cipher/login.dart';
import 'item.dart';
import 'public_suffix_list.dart';

/// The logins Bitwarden suggests for the page at [url]: out of the trash and
/// the archive, with a URI that [uriMatches] it.
List<Item> itemsForUrl(Iterable<Item> items, String url) => [
  for (final item in items)
    if (item.cipher.type == CipherType.login &&
        !item.cipher.isDeleted &&
        !item.cipher.isArchived &&
        (item.cipher.login?.uris ?? const <LoginUri>[]).any(
          (uri) => uriMatches(uri, url),
        ))
      item,
];

/// Whether the login URI [uri] matches the page at [url] by its match
/// detection, as Bitwarden's does. Without one, by base domain: the domain
/// registered under a public suffix, so that `https://github.com` matches
/// `https://gist.github.com/alice`.
bool uriMatches(LoginUri uri, String url) {
  final saved = uri.uri;
  if (saved == null || saved.isEmpty || url.isEmpty) return false;
  switch (uri.match ?? UriMatchStrategy.domain) {
    case UriMatchStrategy.domain:
      final domain = _baseDomain(saved);
      return domain != null &&
          domain == _baseDomain(url) &&
          !(_domainExceptions[domain]?.contains(_host(url)) ?? false);
    case UriMatchStrategy.host:
      final host = _host(url);
      return host != null && host == _host(saved);
    case UriMatchStrategy.startsWith:
      return url.startsWith(saved);
    case UriMatchStrategy.exact:
      return url == saved;
    case UriMatchStrategy.regularExpression:
      try {
        return RegExp(saved, caseSensitive: false).hasMatch(url);
      } on FormatException {
        return false;
      }
    default:
      return false;
  }
}

/// Anyone's Apps Script runs on script.google.com.
const _domainExceptions = {
  'google.com': {'script.google.com'},
};

String? _baseDomain(String uri) {
  if (uri.trim().startsWith(RegExp('data:|about:'))) return null;
  final hostname = _hostname(_parse(uri));
  if (hostname == null) return null;
  if (hostname == 'localhost' || hostname.endsWith('.localhost')) {
    return 'localhost';
  }
  if (_isIpAddress(hostname)) return hostname;
  return _registrableDomain(hostname);
}

/// The hostname and the port, unless the scheme's default, as a browser's
/// `URL.host` gives them.
String? _host(String uri) {
  if (!uri.contains('://') && !uri.contains('.')) return null;
  final parsed = _parse(uri);
  final hostname = _hostname(parsed);
  if (hostname == null) return null;
  final host = hostname.contains(':') ? '[$hostname]' : hostname;
  return parsed!.hasPort ? '$host:${parsed.port}' : host;
}

/// http:// when [uri] has no scheme, as Bitwarden reads it.
Uri? _parse(String uri) {
  final trimmed = uri.trim();
  return Uri.tryParse(trimmed.contains('://') ? trimmed : 'http://$trimmed');
}

/// In lowercase ASCII, as browsers give it: Dart percent-encodes a hostname
/// that is not ASCII.
String? _hostname(Uri? uri) {
  if (uri == null || uri.host.isEmpty) return null;
  try {
    final hostname = domainToAscii(
      Uri.decodeComponent(uri.host),
      validate: false,
    );
    return hostname.endsWith('.')
        ? hostname.substring(0, hostname.length - 1)
        : hostname;
  } on FormatException {
    return null;
  }
}

bool _isIpAddress(String hostname) =>
    hostname.contains(':') ||
    RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(hostname);

/// The private domains of the list count, as in Bitwarden: alice.github.io and
/// bob.github.io are two sites.
final _rules = publicSuffixRules.split('\n').toSet();

/// The public suffix of [hostname] and the label before it, by the list's
/// algorithm: the longest rule wins, an exception over a wildcard, and an
/// unknown top-level domain is a public suffix. Null for a public suffix.
String? _registrableDomain(String hostname) {
  final labels = hostname.split('.');
  for (var i = 0; i < labels.length; i++) {
    final suffix = labels.sublist(i).join('.');
    if (_rules.contains('!$suffix')) return suffix;
    if (i == labels.length - 1 ||
        _rules.contains(suffix) ||
        _rules.contains('*.${labels.sublist(i + 1).join('.')}')) {
      return i == 0 ? null : labels.sublist(i - 1).join('.');
    }
  }
  return null;
}
