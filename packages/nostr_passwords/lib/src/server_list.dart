import 'package:ndk/ndk.dart';

import 'private_tags.dart';

/// A vault's Blossom servers, in a BUD-03 server list: the public ones in the
/// tags, the private ones encrypted to the vault in the content, as its
/// relay list does.
///
/// Each list is in order of preference, the first server first.
class ServerList {
  const ServerList({this.public = const [], this.private = const []});

  final List<String> public;
  final List<String> private;

  /// Every server, the public ones first.
  List<String> get urls => [...public, ...private];

  bool get isEmpty => public.isEmpty && private.isEmpty;

  /// Whether [url] is listed, both normalized as [parseServerUrl] does.
  bool contains(String url) =>
      urls.any((server) => _normalized(server) == _normalized(url));

  /// This list with [url], as [parseServerUrl] reads it, last, in place of
  /// the same server listed otherwise.
  ServerList withServer(String url, {bool private = false}) {
    final server =
        parseServerUrl(url) ??
        (throw ArgumentError.value(url, 'url', 'Not a server URL'));
    final rest = without(server);
    return ServerList(
      public: [...rest.public, if (!private) server],
      private: [...rest.private, if (private) server],
    );
  }

  ServerList without(String url) {
    bool isUrl(String server) => _normalized(server) == _normalized(url);
    return ServerList(
      public: [...public]..removeWhere(isUrl),
      private: [...private]..removeWhere(isUrl),
    );
  }

  static String _normalized(String url) => parseServerUrl(url) ?? url;
}

/// A Blossom server address as a user types it, https:// when it has no
/// scheme, without a trailing slash. Returns null for anything else, a host
/// without a dot included, localhost aside.
String? parseServerUrl(String text) {
  final trimmed = text.trim();
  final url = Uri.tryParse(
    trimmed.contains('://') ? trimmed : 'https://$trimmed',
  );
  if (url == null ||
      !(url.isScheme('https') || url.isScheme('http')) ||
      !(url.host.contains('.') || url.host == 'localhost') ||
      url.userInfo.isNotEmpty ||
      url.hasQuery ||
      url.hasFragment) {
    return null;
  }
  return url
      .replace(path: url.path.replaceFirst(RegExp(r'/+$'), ''))
      .toString();
}

/// [createdAt] is now by default.
Future<Nip01Event> signServerList(
  ServerList list,
  EventSigner vault, {
  int? createdAt,
}) async => vault.sign(
  Nip01Event(
    pubKey: vault.getPublicKey(),
    kind: Blossom.kBlossomUserServerList,
    tags: _tags(list.public),
    content: await encryptPrivateTags(_tags(list.private), vault),
    createdAt: createdAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
  ),
);

Future<ServerList> readServerList(Nip01Event event, EventSigner vault) async {
  if (event.kind != Blossom.kBlossomUserServerList ||
      event.pubKey != vault.getPublicKey()) {
    throw FormatException(
      'Event ${event.id} is not a server list of the vault',
    );
  }
  return ServerList(
    public: _servers(event.tags),
    private: _servers(await decryptPrivateTags(event, vault)),
  );
}

List<List<String>> _tags(List<String> servers) => [
  for (final server in servers) ['server', server],
];

List<String> _servers(List<dynamic> tags) => [
  for (final tag in tags)
    if (tag case ['server', final String server, ...]) server,
];
