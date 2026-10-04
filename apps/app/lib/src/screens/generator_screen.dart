import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../context.dart';
import '../generator/generator_settings.dart';
import '../generator/generator_sheet.dart';
import 'app_navigation.dart';

/// The generator on a screen of its own, which saves its options as they
/// change, for the next time and for the sheet of the item form.
class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  GeneratorSettings? _settings;

  /// Starts the view anew, with a new value, when the options changed
  /// elsewhere.
  var _loads = 0;
  var _shown = false;
  Future<void>? _saving;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hidden behind another tab or the lock, while the sheet of the item form
    // may change the options.
    final shown = TickerMode.valuesOf(context).enabled;
    if (shown && !_shown) unawaited(_load());
    _shown = shown;
  }

  Future<void> _load() async {
    if (_saving != null) return;
    final settings = await GeneratorSettings.read();
    final current = _settings;
    if (!mounted ||
        current != null &&
            jsonEncode(settings.toJson()) == jsonEncode(current.toJson())) {
      return;
    }
    setState(() {
      _settings = settings;
      _loads++;
    });
  }

  /// One write at a time, the last options winning, as a slider changes them
  /// many times a second.
  void _change(GeneratorSettings settings) {
    _settings = settings;
    _saving ??= _save();
  }

  Future<void> _save() async {
    GeneratorSettings saved;
    do {
      saved = _settings!;
      await saved.write();
    } while (!identical(saved, _settings));
    _saving = null;
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    return DestinationScaffold(
      destination: AppDestination.generator,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.generator,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                if (settings != null)
                  GeneratorView(
                    key: ValueKey(_loads),
                    settings: settings,
                    onChanged: _change,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
