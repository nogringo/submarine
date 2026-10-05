import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'context.dart';
import 'theme/theme.dart';
import 'widgets/sonar.dart';

/// Shown instead of the app when the secure storage of the device could not
/// be read at launch.
class StorageErrorApp extends StatelessWidget {
  const StorageErrorApp({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final PlatformException error;

  /// Starts the app over, which shows this screen again if it fails again.
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Submarine',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(Palette.light, Brightness.light),
    darkTheme: buildTheme(Palette.dark, Brightness.dark),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: StorageErrorScreen(error: error, onRetry: onRetry),
  );
}

class StorageErrorScreen extends StatefulWidget {
  const StorageErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final PlatformException error;
  final Future<void> Function() onRetry;

  @override
  State<StorageErrorScreen> createState() => _StorageErrorScreenState();
}

class _StorageErrorScreenState extends State<StorageErrorScreen> {
  var _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    try {
      await widget.onRetry();
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: Sonar(size: 180)),
                  const SizedBox(height: 32),
                  Text(
                    'SUBMARINE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: wordmarkFont,
                      fontSize: 40,
                      letterSpacing: 3,
                      color: palette.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.storageReadFailed,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: palette.danger),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.storageReadFailedBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: palette.muted),
                  ),
                  const SizedBox(height: 40),
                  FilledButton.icon(
                    autofocus: true,
                    onPressed: _retrying ? null : _retry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.tryAgain),
                  ),
                  const SizedBox(height: 24),
                  SelectableText(
                    widget.error.message ?? widget.error.code,
                    textAlign: TextAlign.center,
                    style: monoStyle.copyWith(
                      fontSize: 12,
                      color: palette.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
