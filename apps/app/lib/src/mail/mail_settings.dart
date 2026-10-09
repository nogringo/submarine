import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../secure_storage.dart';

/// The lists a new email address publishes.
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

/// The email settings picked on this device.
class MailSettings extends ChangeNotifier {
  MailSettings._(this._bridge, this._urls);

  static const _bridgeKey = 'mailBridge';

  static Future<MailSettings> load() async =>
      MailSettings._(await secureStorage.read(key: _bridgeKey), {
        for (final list in MailList.values)
          if (await secureStorage.read(key: list._key) case final json?)
            list: (jsonDecode(json) as List).cast<String>(),
      });

  static MailSettings of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<MailSettingsScope>()!
      .notifier!;

  /// The domain of the bridge that new email addresses get.
  String get bridge => _bridge ?? defaultMailBridge;
  String? _bridge;

  /// Kept unset for the default bridge, so that it follows a new default.
  Future<void> setBridge(String bridge) async {
    _bridge = bridge == defaultMailBridge ? null : bridge;
    notifyListeners();
    await secureStorage.write(key: _bridgeKey, value: _bridge);
  }

  /// The relays or servers of [list] that new email addresses get.
  List<String> urls(MailList list) => _urls[list] ?? list.defaults;
  final Map<MailList, List<String>> _urls;

  /// Kept unset for the defaults, so that they follow new defaults.
  Future<void> setUrls(MailList list, List<String> urls) async {
    final custom = listEquals(urls, list.defaults) ? null : [...urls];
    if (custom == null) {
      _urls.remove(list);
    } else {
      _urls[list] = custom;
    }
    notifyListeners();
    await secureStorage.write(
      key: list._key,
      value: custom == null ? null : jsonEncode(custom),
    );
  }
}

class MailSettingsScope extends InheritedNotifier<MailSettings> {
  const MailSettingsScope({
    super.key,
    required MailSettings mail,
    required super.child,
  }) : super(notifier: mail);
}
