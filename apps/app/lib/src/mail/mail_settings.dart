import 'package:flutter/widgets.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../secure_storage.dart';

/// The email settings picked on this device.
class MailSettings extends ChangeNotifier {
  MailSettings._(this._bridge);

  static const _bridgeKey = 'mailBridge';

  static Future<MailSettings> load() async =>
      MailSettings._(await secureStorage.read(key: _bridgeKey));

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
}

class MailSettingsScope extends InheritedNotifier<MailSettings> {
  const MailSettingsScope({
    super.key,
    required MailSettings mail,
    required super.child,
  }) : super(notifier: mail);
}
