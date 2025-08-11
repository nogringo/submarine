import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  static void showSuccess({
    required BuildContext context,
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 3),
  }) {
    toastification.show(
      context: context,
      title: Text(title),
      description: description != null ? Text(description) : null,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: duration,
      alignment: Alignment.bottomCenter,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      icon: Icon(
        Icons.check_circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        width: 1,
      ),
    );
  }

  static void showError({
    required BuildContext context,
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 3),
  }) {
    toastification.show(
      context: context,
      title: Text(title),
      description: description != null ? Text(description) : null,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      autoCloseDuration: duration,
      alignment: Alignment.bottomCenter,
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
      icon: Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      ),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        width: 1,
      ),
    );
  }
}
