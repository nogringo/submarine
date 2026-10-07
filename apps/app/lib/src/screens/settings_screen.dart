import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ndk/ndk.dart' show Nip19;

import '../clipboard.dart';
import '../context.dart';
import '../items/field_tile.dart';
import '../lock/app_lock.dart';
import '../lock/lock_password_dialog.dart';
import '../lock/lock_screen.dart';
import '../router.dart';
import '../screen_capture.dart';
import '../theme/appearance.dart';
import '../theme/theme.dart';
import '../vaults/vault_controller.dart';
import '../vaults/vaults.dart';
import '../widgets/settings_tile.dart';
import '../widgets/vault_avatar.dart';
import 'add_vault.dart';
import 'app_navigation.dart';
import 'import_export.dart';

/// The settings of the app.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const DestinationScaffold(
    destination: AppDestination.settings,
    child: _Settings(),
  );
}

class _Settings extends StatelessWidget {
  const _Settings();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lock = AppLock.of(context);
    final clipboard = AppClipboard.of(context);
    final screenCapture = ScreenCapture.of(context);
    final vaults = Vaults.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.settings,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              SettingsSection(
                title: l10n.vaults,
                child: FieldCard(
                  children: [
                    for (final vault in vaults.all) _VaultTile(vault: vault),
                    SettingsTile(
                      leading: const AddVaultMark(size: 36),
                      title: Text(l10n.addVault),
                      onTap: () => addVault(context),
                    ),
                  ],
                ),
              ),
              SettingsSection(
                title: l10n.security,
                child: FieldCard(
                  children: [
                    const _PasswordTile(),
                    if (DeviceAuth.supportedPlatform) const _BiometricsTile(),
                    if (lock.enabled)
                      _MenuTile(
                        title: l10n.lockAfter,
                        value: lock.timeout,
                        values: LockTimeout.values,
                        label: (timeout) => lockTimeoutLabel(l10n, timeout),
                        onSelected: lock.setTimeout,
                      ),
                    _MenuTile(
                      title: l10n.clearClipboardAfter,
                      value: clipboard.timeout,
                      values: ClipboardTimeout.values,
                      label: (timeout) => _clipboardTimeoutLabel(l10n, timeout),
                      onSelected: clipboard.setTimeout,
                    ),
                    if (ScreenCapture.supported)
                      SettingsTile(
                        title: Text(l10n.allowScreenCapture),
                        subtitle: Text(l10n.allowScreenCaptureDescription),
                        trailing: Switch(
                          value: screenCapture.allowed,
                          onChanged: screenCapture.setAllowed,
                        ),
                      ),
                  ],
                ),
              ),
              SettingsSection(
                title: l10n.appearance,
                child: const FieldCard(
                  children: [_LanguageTile(), _ThemeTile()],
                ),
              ),
              const ImportExportSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _VaultTile extends StatelessWidget {
  const _VaultTile({required this.vault});

  final VaultController vault;

  @override
  Widget build(BuildContext context) => SettingsTile(
    leading: VaultAvatar(vault: vault, size: 36),
    title: Text(vault.name, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text(
      Nip19.encodePubKey(vault.pubkey),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: monoStyle.copyWith(fontSize: 12),
    ),
    trailing: Icon(Icons.chevron_right_rounded, color: context.palette.muted),
    onTap: () => context.push(vaultSettingsPath(vault.pubkey)),
  );
}

class _PasswordTile extends StatelessWidget {
  const _PasswordTile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lock = AppLock.of(context);
    void open(LockPasswordChange change) => showDialog<void>(
      context: context,
      builder: (context) => LockPasswordDialog(change: change),
    );
    return SettingsTile(
      title: Text(l10n.lockPassword),
      subtitle: Text(l10n.lockPasswordDescription),
      trailing: lock.hasPassword
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => open(LockPasswordChange.change),
                  child: Text(l10n.changeLockPassword),
                ),
                TextButton(
                  onPressed: () => open(LockPasswordChange.remove),
                  child: Text(l10n.removeLockPassword),
                ),
              ],
            )
          : TextButton(
              onPressed: () => open(LockPasswordChange.set),
              child: Text(l10n.setLockPassword),
            ),
    );
  }
}

class _BiometricsTile extends StatefulWidget {
  const _BiometricsTile();

  @override
  State<_BiometricsTile> createState() => _BiometricsTileState();
}

class _BiometricsTileState extends State<_BiometricsTile> {
  Future<bool>? _available;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _available ??= AppLock.of(context).isAvailable();
  }

  Future<void> _toggle(AppLock lock, bool enabled) async {
    final l10n = context.l10n;
    setState(() => _error = null);
    if (!enabled) return lock.disableBiometrics();
    try {
      await lock.enableBiometrics(l10n.enableLockReason);
    } on LocalAuthException catch (error) {
      if (mounted) setState(() => _error = authErrorMessage(l10n, error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final lock = AppLock.of(context);
    return FutureBuilder(
      future: _available,
      builder: (context, snapshot) {
        // Turning biometrics off never waits for the device.
        final canToggle = lock.biometrics || snapshot.data == true;
        final unavailable = snapshot.data == false && !lock.biometrics;
        final error = _error;
        return SettingsTile(
          title: Text(l10n.unlockWithBiometrics),
          subtitle: error != null
              ? Text(error, style: TextStyle(color: palette.danger))
              : Text(
                  unavailable
                      ? l10n.lockNeedsScreenLock
                      : lock.hasPassword
                      ? l10n.unlockWithBiometricsWithPassword
                      : l10n.unlockWithBiometricsDescription,
                ),
          trailing: Switch(
            value: lock.biometrics,
            onChanged: canToggle && !lock.checking
                ? (enabled) => _toggle(lock, enabled)
                : null,
          ),
        );
      },
    );
  }
}

/// A setting picked from a menu of [values].
class _MenuTile<T> extends StatelessWidget {
  const _MenuTile({
    required this.title,
    required this.value,
    required this.values,
    required this.label,
    required this.onSelected,
  });

  final String title;
  final T value;
  final List<T> values;
  final String Function(T value) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Text(title),
      trailing: PopupMenuButton<T>(
        initialValue: value,
        tooltip: title,
        onSelected: onSelected,
        itemBuilder: (context) => [
          for (final value in values)
            PopupMenuItem(value: value, child: Text(label(value))),
        ],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(label(value), style: const TextStyle(fontSize: 15)),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down_rounded, color: context.palette.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile();

  /// Stands for the system's language, as a menu item's value cannot be null.
  static const _system = Locale('und');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appearance = Appearance.of(context);
    String name(Locale locale) => locale == _system
        ? l10n.languageSystem
        : lookupAppLocalizations(locale).languageName;
    return _MenuTile(
      title: l10n.language,
      value: appearance.locale ?? _system,
      values: [
        _system,
        ...[...AppLocalizations.supportedLocales]
          ..sort((a, b) => name(a).compareTo(name(b))),
      ],
      label: name,
      onSelected: (locale) =>
          appearance.setLocale(locale == _system ? null : locale),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appearance = Appearance.of(context);
    final wide = context.isWide;
    final picker = SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      expandedInsets: wide ? null : EdgeInsets.zero,
      segments: [
        ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem)),
        ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
        ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
      ],
      selected: {appearance.themeMode},
      onSelectionChanged: (selected) =>
          appearance.setThemeMode(selected.single),
    );
    return SettingsTile(
      title: Text(l10n.theme),
      trailing: wide ? picker : null,
      below: wide ? null : picker,
    );
  }
}

String lockTimeoutLabel(AppLocalizations l10n, LockTimeout timeout) =>
    switch (timeout.idle) {
      null when timeout == LockTimeout.immediately => l10n.lockImmediately,
      null => l10n.lockOnRestart,
      final idle when idle.inHours > 0 => l10n.hours(idle.inHours),
      final idle => l10n.minutes(idle.inMinutes),
    };

String _clipboardTimeoutLabel(
  AppLocalizations l10n,
  ClipboardTimeout timeout,
) => switch (timeout.delay) {
  null => l10n.never,
  final delay when delay.inMinutes > 0 => l10n.minutes(delay.inMinutes),
  final delay => l10n.seconds(delay.inSeconds),
};
