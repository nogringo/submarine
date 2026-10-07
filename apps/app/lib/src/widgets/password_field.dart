import 'package:flutter/material.dart';

import '../context.dart';
import '../theme/theme.dart';

/// A password the user types, hidden until [onToggleHidden] shows it.
class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.hidden,
    this.onToggleHidden,
    this.autofocus = false,
    this.errorText,
    this.helperText,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool hidden;
  final VoidCallback? onToggleHidden;
  final bool autofocus;
  final String? errorText;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onToggleHidden = this.onToggleHidden;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      obscureText: hidden,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      style: monoStyle,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        errorMaxLines: 3,
        helperText: helperText,
        helperMaxLines: 3,
        suffixIcon: onToggleHidden == null
            ? null
            : IconButton(
                tooltip: hidden ? l10n.show : l10n.hide,
                onPressed: onToggleHidden,
                icon: Icon(
                  hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
      ),
    );
  }
}
