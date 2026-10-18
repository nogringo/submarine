import 'dart:convert';

import 'package:nostr_passwords/nostr_passwords.dart';

import 'core.dart';
import 'vaults.dart';

/// The lists a new email address publishes, by the names the popup uses.
enum MailList {
  /// Its NIP-65 list, where the bridge finds its inbox.
  address('mailRelays', defaultMailboxRelays),

  /// Its `kind:10050` list, the relays its emails arrive on.
  inbox('mailInboxRelays', defaultMailboxInboxRelays),

  /// Its `kind:10063` list, the Blossom servers its large emails arrive on.
  servers('mailBlossomServers', defaultMailboxBlossomServers);

  const MailList(this._key, this.defaults);

  final String _key;
  final List<String> defaults;
}

/// The email settings picked on this device, kept under the app's names. A
/// default is kept unset, so that it follows a new default.
class MailSettings {
  MailSettings(this._store);

  final KeyValueStore _store;

  static const _bridgeKey = 'mailBridge';

  /// The domain of the bridge that new email addresses get.
  Future<String> bridge() async =>
      await _store.read(_bridgeKey) ?? defaultMailBridge;

  /// Saves the bridge of [text], as a user types it.
  Future<void> setBridge(String text) async {
    final bridge = parseMailBridge(text);
    if (bridge == null) throw CoreException('invalidBridge', text);
    if (bridge == defaultMailBridge) return _store.remove(_bridgeKey);
    await _store.write(_bridgeKey, bridge);
  }

  /// The relays or servers of [list] that new email addresses get.
  Future<List<String>> urls(MailList list) async =>
      switch (await _store.read(list._key)) {
        final json? => (jsonDecode(json) as List).cast<String>(),
        null => list.defaults,
      };

  Future<void> setUrls(MailList list, List<String> urls) async {
    if (_sameUrls(urls, list.defaults)) return _store.remove(list._key);
    await _store.write(list._key, jsonEncode(urls));
  }

  Future<Map<String, Object?>> toJson() async => {
    'bridge': await bridge(),
    'defaultBridge': defaultMailBridge,
    for (final list in MailList.values)
      list.name: {'urls': await urls(list), 'defaults': list.defaults},
  };
}

bool _sameUrls(List<String> a, List<String> b) =>
    a.length == b.length &&
    Iterable<int>.generate(a.length).every((i) => a[i] == b[i]);
