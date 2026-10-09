import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../secure_storage.dart';

/// The relay lists a new email address publishes.
enum MailRelayList {
  /// Its NIP-65 list, where the bridge finds its inbox.
  address('mailRelays', defaultMailboxRelays),

  /// Its `kind:10050` list, the relays its emails arrive on.
  inbox('mailInboxRelays', defaultMailboxInboxRelays);

  const MailRelayList(this._key, this.defaults);

  final String _key;
  final List<String> defaults;
}

/// The email settings picked on this device.
class MailSettings extends ChangeNotifier {
  MailSettings._(this._bridge, this._relays);

  static const _bridgeKey = 'mailBridge';

  static Future<MailSettings> load() async =>
      MailSettings._(await secureStorage.read(key: _bridgeKey), {
        for (final list in MailRelayList.values)
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

  /// The relays of [list] that new email addresses get.
  List<String> relays(MailRelayList list) => _relays[list] ?? list.defaults;
  final Map<MailRelayList, List<String>> _relays;

  /// Kept unset for the default relays, so that they follow new defaults.
  Future<void> setRelays(MailRelayList list, List<String> relays) async {
    final custom = listEquals(relays, list.defaults) ? null : [...relays];
    if (custom == null) {
      _relays.remove(list);
    } else {
      _relays[list] = custom;
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
