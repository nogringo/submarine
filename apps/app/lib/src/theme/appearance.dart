import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../secure_storage.dart';

/// The theme and the language picked on this device.
class Appearance extends ChangeNotifier {
  Appearance._(this._themeMode, this._locale);

  static const _themeKey = 'theme';
  static const _localeKey = 'locale';

  static Future<Appearance> load() async {
    final theme = await secureStorage.read(key: _themeKey);
    final tag = await secureStorage.read(key: _localeKey);
    return Appearance._(
      ThemeMode.values.asNameMap()[theme] ?? ThemeMode.system,
      AppLocalizations.supportedLocales
          .where((locale) => locale.toLanguageTag() == tag)
          .firstOrNull,
    );
  }

  static Appearance of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppearanceScope>()!.notifier!;

  ThemeMode get themeMode => _themeMode;
  ThemeMode _themeMode;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();
    await secureStorage.write(key: _themeKey, value: themeMode.name);
  }

  /// The language of the app, or null to follow the system's.
  Locale? get locale => _locale;
  Locale? _locale;

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    await secureStorage.write(key: _localeKey, value: locale?.toLanguageTag());
  }
}

class AppearanceScope extends InheritedNotifier<Appearance> {
  const AppearanceScope({
    super.key,
    required Appearance appearance,
    required super.child,
  }) : super(notifier: appearance);
}
