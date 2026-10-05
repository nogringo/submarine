import 'package:flutter/material.dart';

import '../secure_storage.dart';

/// The theme picked on this device: the system's, light or dark.
class Appearance extends ChangeNotifier {
  Appearance._(this._themeMode);

  static const _key = 'theme';

  static Future<Appearance> load() async {
    final name = await secureStorage.read(key: _key);
    return Appearance._(ThemeMode.values.asNameMap()[name] ?? ThemeMode.system);
  }

  static Appearance of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppearanceScope>()!.notifier!;

  ThemeMode get themeMode => _themeMode;
  ThemeMode _themeMode;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();
    await secureStorage.write(key: _key, value: themeMode.name);
  }
}

class AppearanceScope extends InheritedNotifier<Appearance> {
  const AppearanceScope({
    super.key,
    required Appearance appearance,
    required super.child,
  }) : super(notifier: appearance);
}
