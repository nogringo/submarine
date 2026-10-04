import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../items/field_tile.dart';
import '../theme/theme.dart';
import '../widgets/copy_button.dart';
import '../widgets/select_chip.dart';
import 'generator_settings.dart';

/// Opens the generator with its last options, and returns what the user chose
/// to use, if anything.
Future<String?> showGenerator(BuildContext context) async {
  final initial = await GeneratorSettings.read();
  if (!context.mounted) return null;
  var settings = initial;
  final value = await showModalBottomSheet<String>(
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
              context.l10n.generator,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            GeneratorView(
              settings: initial,
              onChanged: (changed) => settings = changed,
              onUse: (value) => Navigator.pop(context, value),
            ),
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
    this.onUse,
  });

  final GeneratorSettings settings;
  final ValueChanged<GeneratorSettings> onChanged;
  final ValueChanged<String>? onUse;

  @override
  State<GeneratorView> createState() => _GeneratorViewState();
}

class _GeneratorViewState extends State<GeneratorView> {
  late var _settings = widget.settings;
  late var _value = _settings.generate();
  late final _separator = TextEditingController(
    text: _settings.passphrase.wordSeparator,
  );

  @override
  void dispose() {
    _separator.dispose();
    super.dispose();
  }

  void _change(GeneratorSettings settings) {
    setState(() {
      _settings = settings;
      _value = settings.generate();
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
          onRegenerate: () => setState(() => _value = _settings.generate()),
        ),
        const SizedBox(height: 16),
        Row(
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
            const SizedBox(width: 8),
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
        const SizedBox(height: 12),
        if (isPassword)
          ..._passwordOptions(l10n)
        else
          ..._passphraseOptions(l10n),
        if (onUse != null) ...[
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => onUse(_value),
            child: Text(isPassword ? l10n.usePassword : l10n.usePassphrase),
          ),
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
        // Lines the thumb up with the labels at both ends.
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        onChanged: (length) =>
            _changePassword(options.copyWith(length: length.round())),
      ),
      const SizedBox(height: 8),
      _Label(l10n.includeCharacters),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
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
      const SizedBox(height: 8),
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
      SwitchListTile(
        value: options.avoidAmbiguous,
        onChanged: (avoid) =>
            _changePassword(options.copyWith(avoidAmbiguous: avoid)),
        title: Text(l10n.avoidAmbiguous),
        contentPadding: EdgeInsets.zero,
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
      SwitchListTile(
        value: options.capitalize,
        onChanged: (capitalize) =>
            _changePassphrase(options.copyWith(capitalize: capitalize)),
        title: Text(l10n.capitalize),
        contentPadding: EdgeInsets.zero,
      ),
      SwitchListTile(
        value: options.includeNumber,
        onChanged: (include) =>
            _changePassphrase(options.copyWith(includeNumber: include)),
        title: Text(l10n.includeNumber),
        contentPadding: EdgeInsets.zero,
      ),
    ];
  }
}

const _rowLabelStyle = TextStyle(fontSize: 16);

class _Preview extends StatelessWidget {
  const _Preview({required this.value, required this.onRegenerate});

  final String value;
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
          CopyButton(value: value, sensitive: true),
        ],
      ),
    );
  }
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
