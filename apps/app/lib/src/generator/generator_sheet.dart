import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../items/field_tile.dart';
import '../theme/theme.dart';
import '../widgets/copy_button.dart';
import '../widgets/dialog_buttons.dart';
import '../widgets/select_chip.dart';
import 'generator_settings.dart';

/// Opens the generator of passwords, or of [username]s, with its last options,
/// and returns what the user chose to use, if anything. It is a dialog on a
/// wide screen and a sheet on a phone.
Future<String?> showGenerator(
  BuildContext context, {
  bool username = false,
}) async {
  final initial = await GeneratorSettings.read();
  if (!context.mounted) return null;
  var settings = initial;
  final title = username
      ? context.l10n.generateUsername
      : context.l10n.generator;
  GeneratorView view(BuildContext context, {required bool inDialog}) =>
      GeneratorView(
        settings: initial,
        username: username,
        onChanged: (changed) => settings = changed,
        onUse: (value) => Navigator.pop(context, value),
        onCancel: inDialog ? () => Navigator.pop(context) : null,
      );
  final value = context.isWide
      ? await showDialog<String>(
          context: context,
          builder: (context) => Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).dialogTheme.titleTextStyle,
                    ),
                    const SizedBox(height: 20),
                    view(context, inDialog: true),
                  ],
                ),
              ),
            ),
          ),
        )
      : await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                20 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  view(context, inDialog: false),
                ],
              ),
            ),
          ),
        );
  if (!identical(settings, initial)) await settings.write();
  return value;
}

/// A value generated with [settings], the options to change them, and a
/// button to [onUse] the value if given.
class GeneratorView extends StatefulWidget {
  const GeneratorView({
    super.key,
    required this.settings,
    required this.onChanged,
    this.username = false,
    this.onUse,
    this.onCancel,
  });

  final GeneratorSettings settings;

  /// Generates a username rather than a password or a passphrase.
  final bool username;
  final ValueChanged<GeneratorSettings> onChanged;
  final ValueChanged<String>? onUse;

  /// A Cancel button next to the one that uses the value, both on the right,
  /// as in a dialog. Without it, the button takes the whole width.
  final VoidCallback? onCancel;

  @override
  State<GeneratorView> createState() => _GeneratorViewState();
}

class _GeneratorViewState extends State<GeneratorView> {
  late var _settings = widget.settings;
  late var _value = _generate();
  late final _separator = TextEditingController(
    text: _settings.passphrase.wordSeparator,
  );

  @override
  void dispose() {
    _separator.dispose();
    super.dispose();
  }

  String _generate() => widget.username
      ? generateUsername(_settings.username)
      : _settings.generate();

  void _change(GeneratorSettings settings) {
    setState(() {
      _settings = settings;
      _value = _generate();
    });
    widget.onChanged(settings);
  }

  /// Keeps the length the password gets, so that lowering a minimum later
  /// does not shorten it.
  void _changePassword(PasswordGeneratorOptions options) {
    options = options.copyWith(length: options.effectiveLength);
    if (mapEquals(options.toJson(), _settings.password.toJson())) return;
    _change(_settings.copyWith(password: options));
  }

  void _changePassphrase(PassphraseGeneratorOptions options) =>
      _change(_settings.copyWith(passphrase: options));

  void _changeUsername(UsernameGeneratorOptions options) =>
      _change(_settings.copyWith(username: options));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPassword = _settings.type == GeneratorType.password;
    final onUse = widget.onUse;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Preview(
          value: _value,
          sensitive: !widget.username,
          onRegenerate: () => setState(() => _value = _generate()),
        ),
        // The chips take 6 more around them, to be tapped.
        SizedBox(height: widget.username ? 16 : 10),
        if (widget.username)
          ..._usernameOptions(l10n)
        else ...[
          Wrap(
            spacing: 8,
            children: [
              SelectChip(
                label: l10n.password,
                selected: isPassword,
                onTap: isPassword
                    ? null
                    : () => _change(
                        _settings.copyWith(type: GeneratorType.password),
                      ),
              ),
              SelectChip(
                label: l10n.passphrase,
                selected: !isPassword,
                onTap: isPassword
                    ? () => _change(
                        _settings.copyWith(type: GeneratorType.passphrase),
                      )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (isPassword)
            ..._passwordOptions(l10n)
          else
            ..._passphraseOptions(l10n),
        ],
        if (onUse != null) ...[
          const SizedBox(height: 20),
          _actions(l10n, onUse, isPassword),
        ],
      ],
    );
  }

  List<Widget> _passwordOptions(AppLocalizations l10n) {
    final options = _settings.password;
    final enabledSets = [
      options.uppercase,
      options.lowercase,
      options.numbers,
      options.special,
    ].where((enabled) => enabled).length;

    /// The last enabled set stays enabled, as in Bitwarden.
    VoidCallback? toggle(
      bool enabled,
      PasswordGeneratorOptions Function(bool enabled) change,
    ) => enabled && enabledSets == 1
        ? null
        : () => _changePassword(change(!enabled));

    const minLength = PasswordGeneratorOptions.minLength;
    const maxLength = PasswordGeneratorOptions.maxLength;
    const maxCount = PasswordGeneratorOptions.maxMinCount;
    return [
      _CountRow(
        label: l10n.passwordLength,
        value: options.effectiveLength,
        min: minLength,
        max: maxLength,
        onChanged: (length) =>
            _changePassword(options.copyWith(length: length)),
      ),
      Slider(
        value: options.effectiveLength.toDouble(),
        min: minLength.toDouble(),
        max: maxLength.toDouble(),
        divisions: maxLength - minLength,
        semanticFormatterCallback: (length) =>
            l10n.characterCount(length.round()),
        // Lines the thumb up with the labels at both ends.
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        onChanged: (length) =>
            _changePassword(options.copyWith(length: length.round())),
      ),
      const SizedBox(height: 8),
      _Label(l10n.includeCharacters),
      const SizedBox(height: 2),
      Wrap(
        spacing: 8,
        children: [
          SelectChip(
            label: 'A-Z',
            semanticsLabel: l10n.uppercaseLetters,
            selected: options.uppercase,
            onTap: toggle(
              options.uppercase,
              (enabled) => options.copyWith(uppercase: enabled),
            ),
          ),
          SelectChip(
            label: 'a-z',
            semanticsLabel: l10n.lowercaseLetters,
            selected: options.lowercase,
            onTap: toggle(
              options.lowercase,
              (enabled) => options.copyWith(lowercase: enabled),
            ),
          ),
          SelectChip(
            label: '0-9',
            semanticsLabel: l10n.digits,
            selected: options.numbers,
            onTap: toggle(
              options.numbers,
              (enabled) => options.copyWith(numbers: enabled),
            ),
          ),
          SelectChip(
            label: r'!@#$%^&*',
            semanticsLabel: l10n.specialCharacters,
            selected: options.special,
            onTap: toggle(
              options.special,
              (enabled) => options.copyWith(special: enabled),
            ),
          ),
        ],
      ),
      const SizedBox(height: 2),
      _CountRow(
        label: l10n.minNumbers,
        value: options.minNumber.clamp(1, maxCount),
        min: 1,
        max: maxCount,
        onChanged: options.numbers
            ? (count) => _changePassword(options.copyWith(minNumber: count))
            : null,
      ),
      _CountRow(
        label: l10n.minSpecial,
        value: options.minSpecial.clamp(1, maxCount),
        min: 1,
        max: maxCount,
        onChanged: options.special
            ? (count) => _changePassword(options.copyWith(minSpecial: count))
            : null,
      ),
      _SwitchRow(
        label: l10n.avoidAmbiguous,
        value: options.avoidAmbiguous,
        onChanged: (avoid) =>
            _changePassword(options.copyWith(avoidAmbiguous: avoid)),
      ),
    ];
  }

  List<Widget> _passphraseOptions(AppLocalizations l10n) {
    final options = _settings.passphrase;
    return [
      _CountRow(
        label: l10n.numberOfWords,
        value: options.numWords.clamp(
          PassphraseGeneratorOptions.minWords,
          PassphraseGeneratorOptions.maxWords,
        ),
        min: PassphraseGeneratorOptions.minWords,
        max: PassphraseGeneratorOptions.maxWords,
        onChanged: (count) =>
            _changePassphrase(options.copyWith(numWords: count)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(l10n.wordSeparator, style: _rowLabelStyle)),
            SizedBox(
              width: 56,
              child: TextField(
                controller: _separator,
                maxLength: 1,
                textAlign: TextAlign.center,
                autocorrect: false,
                enableSuggestions: false,
                style: monoStyle.copyWith(fontSize: 18),
                decoration: const InputDecoration(
                  counterText: '',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (separator) => _changePassphrase(
                  options.copyWith(wordSeparator: separator),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
      _SwitchRow(
        label: l10n.capitalize,
        value: options.capitalize,
        onChanged: (capitalize) =>
            _changePassphrase(options.copyWith(capitalize: capitalize)),
      ),
      _SwitchRow(
        label: l10n.includeNumber,
        value: options.includeNumber,
        onChanged: (include) =>
            _changePassphrase(options.copyWith(includeNumber: include)),
      ),
    ];
  }

  Widget _actions(
    AppLocalizations l10n,
    ValueChanged<String> onUse,
    bool isPassword,
  ) {
    final use = FilledButton(
      onPressed: () => onUse(_value),
      child: Text(
        widget.username
            ? l10n.useUsername
            : isPassword
            ? l10n.usePassword
            : l10n.usePassphrase,
      ),
    );
    final onCancel = widget.onCancel;
    if (onCancel == null) return use;
    return DialogButtons(
      children: [
        TextButton(onPressed: onCancel, child: Text(l10n.cancel)),
        use,
      ],
    );
  }

  List<Widget> _usernameOptions(AppLocalizations l10n) {
    final options = _settings.username;
    return [
      _SwitchRow(
        label: l10n.usernameCapitalize,
        value: options.capitalize,
        onChanged: (capitalize) =>
            _changeUsername(options.copyWith(capitalize: capitalize)),
      ),
      _SwitchRow(
        label: l10n.usernameIncludeNumber,
        value: options.includeNumber,
        onChanged: (include) =>
            _changeUsername(options.copyWith(includeNumber: include)),
      ),
    ];
  }
}

const _rowLabelStyle = TextStyle(fontSize: 16);

class _Preview extends StatelessWidget {
  const _Preview({
    required this.value,
    required this.sensitive,
    required this.onRegenerate,
  });

  final String value;
  final bool sensitive;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.line),
      ),
      child: Row(
        children: [
          Expanded(child: PasswordText(value)),
          IconButton(
            tooltip: context.l10n.regenerate,
            onPressed: onRegenerate,
            icon: const Icon(Icons.refresh_rounded),
          ),
          CopyButton(value: value, sensitive: sensitive),
        ],
      ),
    );
  }
}

/// A switch with its label, which toggles it too. No hover band, which would
/// run into the label, lined up with the other rows.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text(label, style: _rowLabelStyle)),
              const SizedBox(width: 12),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(fontSize: 13, color: context.palette.muted));
}

/// A number from [min] to [max], one step at a time. Null [onChanged]
/// disables it.
class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final onChanged = this.onChanged;
    final color = onChanged == null ? palette.muted : palette.text;
    return Row(
      children: [
        Expanded(
          child: Text(label, style: _rowLabelStyle.copyWith(color: color)),
        ),
        IconButton(
          tooltip: l10n.decrease,
          onPressed: onChanged != null && value > min
              ? () => onChanged(value - 1)
              : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: monoStyle.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
        IconButton(
          tooltip: l10n.increase,
          onPressed: onChanged != null && value < max
              ? () => onChanged(value + 1)
              : null,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}
