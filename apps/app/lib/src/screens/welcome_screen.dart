import 'package:flutter/material.dart';

import '../context.dart';
import '../theme/theme.dart';
import '../widgets/sonar.dart';
import 'add_vault.dart';

/// Shown until the first vault is added.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
                  const Center(child: Sonar(size: 220)),
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
                    l10n.welcomeTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: palette.muted),
                  ),
                  const SizedBox(height: 40),
                  FilledButton.icon(
                    onPressed: () =>
                        addVaultWith(context, AddVaultChoice.create),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.createVault),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => addVaultWith(context, AddVaultChoice.open),
                    icon: const Icon(Icons.key_rounded),
                    label: Text(l10n.openVault),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => _showNostr(context),
                      style: TextButton.styleFrom(
                        foregroundColor: palette.muted,
                      ),
                      child: Text(l10n.builtOnNostr),
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

Future<void> _showNostr(BuildContext context) {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.builtOnNostr),
      content: Text(l10n.builtOnNostrBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}
