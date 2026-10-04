import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../context.dart';
import 'vault_navigation.dart';

/// The top-level screens, in the order of the router's branches.
enum AppDestination { vaults, generator, settings }

/// Narrow layout: the top-level screens, at the bottom of each of them. Back
/// from the generator or the settings goes to the vaults, as on Android.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({super.key, required this.current});

  final AppDestination current;

  void _go(BuildContext context, AppDestination destination) =>
      StatefulNavigationShell.of(context).goBranch(destination.index);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: current == AppDestination.vaults,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(context, AppDestination.vaults);
      },
      child: NavigationBar(
        selectedIndex: current.index,
        onDestinationSelected: (index) =>
            _go(context, AppDestination.values[index]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.key_outlined),
            selectedIcon: const Icon(Icons.key_rounded),
            label: l10n.vaultTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.casino_outlined),
            selectedIcon: const Icon(Icons.casino_rounded),
            label: l10n.generator,
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_rounded),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}

/// A top-level screen other than the vaults: next to the rail in the wide
/// layout, above the bottom bar in the narrow one.
class DestinationScaffold extends StatelessWidget {
  const DestinationScaffold({
    super.key,
    required this.destination,
    required this.child,
  });

  final AppDestination destination;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!context.isWide) {
      return Scaffold(
        body: SafeArea(bottom: false, child: child),
        bottomNavigationBar: AppNavigationBar(current: destination),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VaultRail(
              selectedVaultId: null,
              selectedItemId: null,
              destination: destination,
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
