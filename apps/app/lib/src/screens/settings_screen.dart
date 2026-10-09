import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ndk/ndk.dart' show Nip19;
import 'package:nostr_passwords/nostr_passwords.dart'
    show defaultMailBridge, parseMailBridge, parseRelayUrl;

import '../clipboard.dart';
import '../context.dart';
import '../items/field_tile.dart';
import '../lock/app_lock.dart';
import '../lock/lock_password_dialog.dart';
import '../lock/lock_screen.dart';
import '../mail/mail_settings.dart';
import '../router.dart';
import '../screen_capture.dart';
import '../theme/appearance.dart';
import '../theme/theme.dart';
import '../vaults/vault_controller.dart';
import '../vaults/vaults.dart';
import '../widgets/dialog_buttons.dart';
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
                title: l10n.emailSettings,
                child: const FieldCard(
                  children: [
                    _MailBridgeTile(),
                    _MailRelaysTile(list: MailRelayList.inbox),
                    _MailRelaysTile(list: MailRelayList.address),
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

class _MailBridgeTile extends StatelessWidget {
  const _MailBridgeTile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mail = MailSettings.of(context);
    return SettingsTile(
      title: Text(l10n.mailBridge),
      subtitle: Text(l10n.mailBridgeDescription(mail.bridge)),
      trailing: TextButton(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => _MailBridgeDialog(mail: mail),
        ),
        child: Text(l10n.changeMailBridge),
      ),
    );
  }
}

class _MailBridgeDialog extends StatefulWidget {
  const _MailBridgeDialog({required this.mail});

  final MailSettings mail;

  @override
  State<_MailBridgeDialog> createState() => _MailBridgeDialogState();
}

class _MailBridgeDialogState extends State<_MailBridgeDialog> {
  late final _domain = TextEditingController(text: widget.mail.bridge);
  String? _error;

  @override
  void dispose() {
    _domain.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _domain.text;
    // Left empty for the default bridge, which the field shows as its hint.
    final bridge = text.trim().isEmpty
        ? defaultMailBridge
        : parseMailBridge(text);
    if (bridge == null) {
      setState(() => _error = context.l10n.mailBridgeInvalid);
      return;
    }
    unawaited(widget.mail.setBridge(bridge));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.mailBridge,
                style: Theme.of(context).dialogTheme.titleTextStyle,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.mailBridgeExplanation,
                style: TextStyle(fontSize: 13, color: context.palette.muted),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _domain,
                autofocus: true,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.url,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l10n.mailBridgeDomain,
                  hintText: defaultMailBridge,
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 24),
              DialogButtons(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(onPressed: _submit, child: Text(l10n.save)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _relayHost(String url) =>
    url.startsWith('wss://') ? url.substring(6) : url;

String _mailRelaysTitle(AppLocalizations l10n, MailRelayList list) =>
    switch (list) {
      MailRelayList.inbox => l10n.mailInboxRelays,
      MailRelayList.address => l10n.mailAddressRelays,
    };

class _MailRelaysTile extends StatelessWidget {
  const _MailRelaysTile({required this.list});

  final MailRelayList list;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mail = MailSettings.of(context);
    return SettingsTile(
      title: Text(_mailRelaysTitle(l10n, list)),
      subtitle: Text(mail.relays(list).map(_relayHost).join(', ')),
      trailing: TextButton(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => _MailRelaysDialog(mail: mail, list: list),
        ),
        child: Text(l10n.changeMailRelays),
      ),
    );
  }
}

class _MailRelaysDialog extends StatefulWidget {
  const _MailRelaysDialog({required this.mail, required this.list});

  final MailSettings mail;
  final MailRelayList list;

  @override
  State<_MailRelaysDialog> createState() => _MailRelaysDialogState();
}

class _MailRelaysDialogState extends State<_MailRelaysDialog> {
  late final _relays = [...widget.mail.relays(widget.list)];
  final _url = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  /// Adds the relay typed, if any. False when the text is not one to add.
  bool _add() {
    final text = _url.text;
    if (text.trim().isEmpty) return true;
    final l10n = context.l10n;
    final url = parseRelayUrl(text);
    final error = url == null
        ? l10n.relayAddressInvalid
        : _relays.contains(url)
        ? l10n.relayAlreadyListed
        : null;
    setState(() {
      _error = error;
      if (url != null && error == null) {
        _relays.add(url);
        _url.clear();
      }
    });
    return error == null;
  }

  void _reset() => setState(() {
    _relays
      ..clear()
      ..addAll(widget.list.defaults);
    _url.clear();
    _error = null;
  });

  // A relay typed but not added yet is saved too.
  void _save() {
    if (!_add()) return;
    unawaited(widget.mail.setRelays(widget.list, _relays));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _mailRelaysTitle(l10n, widget.list),
                style: Theme.of(context).dialogTheme.titleTextStyle,
              ),
              const SizedBox(height: 8),
              Text(switch (widget.list) {
                MailRelayList.inbox => l10n.mailInboxRelaysExplanation,
                MailRelayList.address => l10n.mailAddressRelaysExplanation,
              }, style: TextStyle(fontSize: 13, color: palette.muted)),
              const SizedBox(height: 20),
              if (_relays.isEmpty)
                Text(
                  l10n.mailRelaysNeedOne,
                  style: TextStyle(fontSize: 13, color: palette.muted),
                )
              else
                FieldCard(
                  children: [
                    for (final url in _relays)
                      SettingsTile(
                        leading: Icon(
                          Icons.cell_tower_rounded,
                          size: 20,
                          color: palette.muted,
                        ),
                        title: Text(
                          _relayHost(url),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: IconButton(
                          tooltip: l10n.removeRelay,
                          onPressed: () => setState(() => _relays.remove(url)),
                          icon: const Icon(Icons.close_rounded, size: 20),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _url,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.url,
                onSubmitted: (_) => _add(),
                decoration: InputDecoration(
                  labelText: l10n.relayAddress,
                  hintText: 'wss://relay.example.com',
                  errorText: _error,
                  suffixIcon: IconButton(
                    tooltip: l10n.addRelay,
                    onPressed: _add,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              DialogButtons(
                children: [
                  TextButton(
                    onPressed: listEquals(_relays, widget.list.defaults)
                        ? null
                        : _reset,
                    child: Text(l10n.resetMailRelays),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: _relays.isEmpty ? null : _save,
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
