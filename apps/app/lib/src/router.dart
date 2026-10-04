import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'context.dart';
import 'screens/item_detail.dart';
import 'screens/item_list.dart';
import 'screens/vault_shell.dart';
import 'screens/welcome_screen.dart';
import 'vaults/vaults.dart';

/// Every page is built explicitly: go_router 18 recognizes the MaterialApp of
/// material_ui only, and would fall back to pages without transitions.
GoRouter buildRouter(Vaults vaults) => GoRouter(
  initialLocation: '/vaults/$allVaultsId',
  redirect: (context, state) {
    final welcome = state.matchedLocation == '/welcome';
    if (vaults.isEmpty) return welcome ? null : '/welcome';
    return welcome ? '/vaults/$allVaultsId' : null;
  },
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/vaults/$allVaultsId'),
    GoRoute(
      path: '/welcome',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const WelcomeScreen()),
    ),
    ShellRoute(
      pageBuilder: (context, state, child) => NoTransitionPage(
        key: state.pageKey,
        child: VaultShell(
          vaultId: state.pathParameters['vaultId']!,
          itemId: state.pathParameters['itemId'],
          child: child,
        ),
      ),
      routes: [
        GoRoute(
          path: '/vaults/:vaultId',
          redirect: (context, state) {
            final vaultId = state.pathParameters['vaultId']!;
            final known =
                vaultId == allVaultsId || vaults.byPubkey(vaultId) != null;
            return known ? null : '/vaults/$allVaultsId';
          },
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: context.isWide
                ? const NoItemSelected()
                : ItemListScreen(vaultId: state.pathParameters['vaultId']!),
          ),
          routes: [
            GoRoute(
              path: 'items/:itemId',
              pageBuilder: (context, state) {
                final vaultId = state.pathParameters['vaultId']!;
                final itemId = state.pathParameters['itemId']!;
                return context.isWide
                    ? NoTransitionPage(
                        key: state.pageKey,
                        child: ItemDetailPane(vaultId: vaultId, itemId: itemId),
                      )
                    : MaterialPage(
                        key: state.pageKey,
                        child: ItemScreen(vaultId: vaultId, itemId: itemId),
                      );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
