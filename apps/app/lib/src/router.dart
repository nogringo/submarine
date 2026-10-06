import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import 'context.dart';
import 'items/item_filter.dart';
import 'screens/generator_screen.dart';
import 'screens/item_detail.dart';
import 'screens/item_form.dart';
import 'screens/item_list.dart';
import 'screens/settings_screen.dart';
import 'screens/vault_settings.dart';
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

/// [vaultPath], keeping [itemId] open if that list holds it.
String vaultPathKeeping(
  Vaults vaults,
  String vaultId, {
  ItemFilter filter = ItemFilter.all,
  required String? itemId,
}) {
  final cipher = itemId == null
      ? null
      : vaults.findItem(vaultId, itemId)?.item.cipher;
  return vaultPath(
    vaultId,
    filter: filter,
    itemId: cipher != null && filter.matches(cipher) ? itemId : null,
  );
}

/// The types the item form creates and edits, by their name in the URL of a
/// new item, in the order of the new item menu.
const formTypes = {
  CipherType.login: 'login',
  CipherType.card: 'card',
  CipherType.secureNote: 'note',
};

/// Where an item of [type] is created, next to the items of [vaultId] that
/// [filter] keeps.
String newItemPath(String vaultId, ItemFilter filter, CipherType type) =>
    '${vaultPath(vaultId, filter: filter)}/new/${formTypes[type]}';

String editItemPath(String vaultId, ItemFilter filter, String itemId) =>
    '${vaultPath(vaultId, filter: filter, itemId: itemId)}/edit';

String vaultSettingsPath(String vaultId) => '/vaults/$vaultId/settings';

const generatorPath = '/generator';

const settingsPath = '/settings';

ItemFilter _filterOf(GoRouterState state) =>
    ItemFilter.fromSlug(state.pathParameters['filter']!)!;

/// The type of the new item in the path.
CipherType? _typeOf(GoRouterState state) => formTypes.entries
    .where((entry) => entry.value == state.pathParameters['type'])
    .firstOrNull
    ?.key;

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
    // Before the shell, whose ':filter' would take "settings".
    GoRoute(
      path: '/vaults/:vaultId/settings',
      redirect: (context, state) =>
          vaults.byPubkey(state.pathParameters['vaultId']!) == null
          ? vaultPath(allVaultsId)
          : null,
      pageBuilder: (context, state) => _AdaptivePage(
        key: state.pageKey,
        child: VaultSettingsScreen(vaultId: state.pathParameters['vaultId']!),
      ),
    ),
    // Each branch keeps its screens as they were left, in the order of
    // AppDestination.
    StatefulShellRoute.indexedStack(
      pageBuilder: (context, state, navigationShell) =>
          NoTransitionPage(key: state.pageKey, child: navigationShell),
      branches: [
        StatefulShellBranch(
          initialLocation: vaultPath(allVaultsId),
          routes: [
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
                    if (vaultId != allVaultsId &&
                        vaults.byPubkey(vaultId) == null) {
                      return vaultPath(allVaultsId);
                    }
                    final filter = ItemFilter.fromSlug(
                      state.pathParameters['filter']!,
                    );
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
                      path: 'new/:type',
                      redirect: (context, state) => _typeOf(state) == null
                          ? vaultPath(
                              state.pathParameters['vaultId']!,
                              filter: _filterOf(state),
                            )
                          : null,
                      pageBuilder: (context, state) =>
                          _formPage(context, state),
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
                          pageBuilder: (context, state) =>
                              _formPage(context, state),
                          onExit: (context, state) => ItemForm.confirmExit(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: generatorPath,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const GeneratorScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: settingsPath,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const SettingsScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// The form of the item in the path, or of a new item of the type in the path.
Page<void> _formPage(BuildContext context, GoRouterState state) =>
    _AdaptivePage(
      key: state.pageKey,
      fullscreenDialog: !context.isWide,
      child: _FormScreen(
        vaultId: state.pathParameters['vaultId']!,
        filter: _filterOf(state),
        itemId: state.pathParameters['itemId'],
        type: _typeOf(state) ?? CipherType.login,
      ),
    );

/// A screen of its own on a phone, the item pane on a desktop.
class _FormScreen extends StatefulWidget {
  const _FormScreen({
    required this.vaultId,
    required this.filter,
    required this.itemId,
    required this.type,
  });

  final String vaultId;
  final ItemFilter filter;
  final String? itemId;
  final CipherType type;

  @override
  State<_FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<_FormScreen> {
  /// Keeps what is typed when the layout changes.
  final _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final form = ItemForm(
      key: _formKey,
      vaultId: widget.vaultId,
      filter: widget.filter,
      itemId: widget.itemId,
      type: widget.type,
    );
    return context.isWide ? form : Scaffold(body: SafeArea(child: form));
  }
}

/// Slides in on a phone, as a [MaterialPage] does, and shows at once on a
/// desktop, as a [NoTransitionPage] does. One page type for both: the
/// navigator replaces the route of a page whose type changes, and with it the
/// state of its screen.
class _AdaptivePage extends Page<void> {
  const _AdaptivePage({
    super.key,
    required this.child,
    this.fullscreenDialog = false,
  });

  final Widget child;
  final bool fullscreenDialog;

  @override
  Route<void> createRoute(BuildContext context) => _AdaptivePageRoute(this);
}

class _AdaptivePageRoute extends PageRoute<void>
    with MaterialRouteTransitionMixin<void> {
  _AdaptivePageRoute(_AdaptivePage page) : super(settings: page);

  _AdaptivePage get _page => settings as _AdaptivePage;

  bool get _wide => navigator!.context.isWide;

  @override
  Widget buildContent(BuildContext context) => _page.child;

  @override
  bool get maintainState => true;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  Duration get transitionDuration =>
      _wide ? Duration.zero : super.transitionDuration;

  @override
  Duration get reverseTransitionDuration =>
      _wide ? Duration.zero : super.reverseTransitionDuration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => context.isWide
      ? child
      : super.buildTransitions(context, animation, secondaryAnimation, child);
}
