import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'context.dart';
import 'items/item_filter.dart';
import 'screens/item_detail.dart';
import 'screens/item_form.dart';
import 'screens/item_list.dart';
import 'screens/vault_shell.dart';
import 'screens/welcome_screen.dart';
import 'vaults/vaults.dart';

/// Where the items of [vaultId] that [filter] keeps are listed, with [itemId]
/// open if given.
String vaultPath(
  String vaultId, {
  ItemFilter filter = ItemFilter.all,
  String? itemId,
}) => ['/vaults/$vaultId/${filter.slug}', ?itemId].join('/');

/// Where a login is created, next to the items of [vaultId] that [filter]
/// keeps.
String newItemPath(String vaultId, ItemFilter filter) =>
    '${vaultPath(vaultId, filter: filter)}/new';

String editItemPath(String vaultId, ItemFilter filter, String itemId) =>
    '${vaultPath(vaultId, filter: filter, itemId: itemId)}/edit';

ItemFilter _filterOf(GoRouterState state) =>
    ItemFilter.fromSlug(state.pathParameters['filter']!)!;

/// Every page is built explicitly: go_router 18 recognizes the MaterialApp of
/// material_ui only, and would fall back to pages without transitions.
GoRouter buildRouter(Vaults vaults) => GoRouter(
  initialLocation: vaultPath(allVaultsId),
  redirect: (context, state) {
    final welcome = state.matchedLocation == '/welcome';
    if (vaults.isEmpty) return welcome ? null : '/welcome';
    return welcome ? vaultPath(allVaultsId) : null;
  },
  routes: [
    GoRoute(path: '/', redirect: (context, state) => vaultPath(allVaultsId)),
    GoRoute(
      path: '/welcome',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const WelcomeScreen()),
    ),
    GoRoute(
      path: '/vaults/:vaultId',
      redirect: (context, state) => vaultPath(state.pathParameters['vaultId']!),
    ),
    ShellRoute(
      pageBuilder: (context, state, child) => NoTransitionPage(
        key: state.pageKey,
        child: VaultShell(
          vaultId: state.pathParameters['vaultId']!,
          filter: _filterOf(state),
          itemId: state.pathParameters['itemId'],
          child: child,
        ),
      ),
      routes: [
        GoRoute(
          path: '/vaults/:vaultId/:filter',
          redirect: (context, state) {
            final vaultId = state.pathParameters['vaultId']!;
            if (vaultId != allVaultsId && vaults.byPubkey(vaultId) == null) {
              return vaultPath(allVaultsId);
            }
            final filter = ItemFilter.fromSlug(state.pathParameters['filter']!);
            return filter == null ? vaultPath(vaultId) : null;
          },
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: context.isWide
                ? const NoItemSelected()
                : ItemListScreen(
                    vaultId: state.pathParameters['vaultId']!,
                    filter: _filterOf(state),
                  ),
          ),
          routes: [
            // Before ':itemId', which would take "new" for an id.
            GoRoute(
              path: 'new',
              pageBuilder: (context, state) => _formPage(context, state),
              onExit: (context, state) => ItemForm.confirmExit(),
            ),
            GoRoute(
              path: ':itemId',
              pageBuilder: (context, state) {
                final vaultId = state.pathParameters['vaultId']!;
                final filter = _filterOf(state);
                final itemId = state.pathParameters['itemId']!;
                return context.isWide
                    ? NoTransitionPage(
                        key: state.pageKey,
                        child: ItemDetailPane(
                          vaultId: vaultId,
                          filter: filter,
                          itemId: itemId,
                        ),
                      )
                    : MaterialPage(
                        key: state.pageKey,
                        child: ItemScreen(
                          vaultId: vaultId,
                          filter: filter,
                          itemId: itemId,
                        ),
                      );
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  pageBuilder: (context, state) => _formPage(context, state),
                  onExit: (context, state) => ItemForm.confirmExit(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

/// The form of the item in the path, or of a new login if none.
Page<void> _formPage(BuildContext context, GoRouterState state) {
  final form = ItemForm(
    vaultId: state.pathParameters['vaultId']!,
    filter: _filterOf(state),
    itemId: state.pathParameters['itemId'],
  );
  return context.isWide
      ? NoTransitionPage(key: state.pageKey, child: form)
      : MaterialPage(
          key: state.pageKey,
          fullscreenDialog: true,
          child: Scaffold(body: SafeArea(child: form)),
        );
}
