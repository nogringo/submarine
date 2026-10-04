import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast_memory.dart' show newDatabaseFactoryMemory;
import 'package:submarine/src/app.dart';
import 'package:submarine/src/screens/filter_column.dart';
import 'package:submarine/src/vaults/vault_storage.dart';
import 'package:submarine/src/vaults/vaults.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

void main() {
  late Ndk ndk;
  late Vaults vaults;

  final github = Cipher(
    type: CipherType.login,
    name: 'GitHub',
    notes: 'Recovery codes are in the safe.',
    login: Login(
      uris: [LoginUri('https://github.com')],
      username: 'alice-dev',
      password: 'Tr0ub4dor&3',
    ),
  );

  /// Vaults with no relay, whose cache already holds [items] in a vault named
  /// Personal when there are any, next to an empty Family vault if
  /// [withFamily].
  Future<void> open(
    WidgetTester tester, {
    List<Cipher> items = const [],
    bool withFamily = false,
  }) => tester.runAsync(() async {
    ndk = Ndk(
      NdkConfig(
        cache: MemCacheManager(),
        eventVerifier: Bip340EventVerifier(),
        bootstrapRelays: [],
        logLevel: LogLevel.off,
        pendingDeliveryRetriesEnabled: false,
      ),
    );
    var records = <VaultRecord>[];
    if (items.isNotEmpty) {
      final factory = const Bip340EventSignerFactory();
      final (privateKey, _) = factory.generateKeyPair();
      final signer = factory.create(privateKey: privateKey);
      final vault = Vault(ndk: ndk, signer: signer, relays: const []);
      for (final cipher in items) {
        await vault.createItem(cipher);
      }
      records = [
        VaultRecord(
          privateKey: privateKey,
          name: 'Personal',
          color: vaultColors.first,
        ),
      ];
    }
    if (withFamily) {
      records.add(
        VaultRecord(
          privateKey: const Bip340EventSignerFactory().generateKeyPair().$1,
          name: 'Family',
          color: vaultColors[1],
        ),
      );
    }
    FlutterSecureStorage.setMockInitialValues({
      if (records.isNotEmpty)
        'vaults': jsonEncode([for (final r in records) r.toJson()]),
    });
    vaults = await Vaults.load(
      ndk: ndk,
      engine: SyncEngine(
        ndk,
        store: SembastSyncStore(
          await newDatabaseFactoryMemory().openDatabase('sync'),
        ),
      ),
      storage: VaultStorage(),
      relays: const [],
    );
    while (vaults.all.any((vault) => !vault.loaded)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  });

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await vaults.pauseSync();
      vaults.dispose();
      await ndk.destroy();
    });
  }

  void setScreen(WidgetTester tester, Size size, {Locale? locale}) {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    if (locale != null) tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('welcomes a device without vaults, then creates one', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844));
    await open(tester);
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    expect(find.text('SUBMARINE'), findsOneWidget);
    await tester.tap(find.text('Create a vault'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Family');
    await tester.runAsync(() async {
      await tester.tap(find.text('Create'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await settle(tester);

    expect(find.text('Save the vault key'), findsOneWidget);
    final nsec = tester.widget<SelectableText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            (widget.data?.startsWith('nsec1') ?? false),
      ),
    );
    final privateKey = parseVaultKey(nsec.data!);
    expect(privateKey, vaults.all.single.record.privateKey);
    expect(
      jsonDecode((await const FlutterSecureStorage().read(key: 'vaults'))!),
      [vaults.all.single.record.toJson()],
    );

    await tester.tap(find.text('Done'));
    await settle(tester);

    expect(find.text('Family'), findsOneWidget);
    await close(tester);
  });

  testWidgets('reads an item on a phone, in French', (tester) async {
    setScreen(tester, const Size(390, 844), locale: const Locale('fr'));
    await open(tester, items: [github]);
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    expect(find.text('Tous les coffres'), findsOneWidget);
    expect(find.text('alice-dev'), findsOneWidget);
    await tester.tap(find.text('GitHub'));
    await settle(tester);

    expect(find.text('Nom d\'utilisateur'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
    expect(find.text('Recovery codes are in the safe.'), findsOneWidget);
    expect(find.textContaining('Tr0ub4dor'), findsNothing);
    await tester.tap(find.byTooltip('Afficher'));
    await settle(tester);
    expect(find.textContaining('Tr0ub4dor&3'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(find.text('Tous les coffres'), findsOneWidget);
    await close(tester);
  });

  testWidgets('shows the vaults, the items and the item side by side', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, items: [github]);
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    expect(find.byTooltip('Personal'), findsOneWidget);
    expect(find.text('Select an item to see it here.'), findsOneWidget);
    await tester.tap(find.text('GitHub'));
    await settle(tester);

    expect(find.text('Username'), findsOneWidget);
    expect(find.text('https://github.com'), findsOneWidget);
    expect(find.text('GitHub'), findsNWidgets(2));
    await close(tester);
  });

  testWidgets('filters the items in a column of their own on a desktop', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(
      tester,
      items: [
        github,
        Cipher(
          type: CipherType.secureNote,
          name: 'Alarm code',
          secureNote: SecureNote(),
        ),
        Cipher(
          type: CipherType.login,
          name: 'Old bank',
          login: Login(username: 'alice'),
          deletedDate: DateTime.utc(2026, 10, 1),
        ),
        Cipher(
          type: CipherType.login,
          name: 'Old mail',
          archivedDate: DateTime.utc(2026, 10, 2),
        ),
      ],
    );
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    Finder countOf(String filter) => find.descendant(
      of: find
          .ancestor(
            of: find.descendant(
              of: find.byType(FilterColumn),
              matching: find.text(filter),
            ),
            matching: find.byType(Row),
          )
          .first,
      matching: find.byWidgetPredicate(
        (widget) => widget is Text && int.tryParse(widget.data ?? '') != null,
      ),
    );
    // Submarine does not support the archive yet.
    expect(tester.widget<Text>(countOf('All items')).data, '3');
    expect(tester.widget<Text>(countOf('Logins')).data, '2');
    expect(find.text('Old mail'), findsOneWidget);
    expect(find.text('Archive'), findsNothing);
    expect(tester.widget<Text>(countOf('Secure notes')).data, '1');
    expect(tester.widget<Text>(countOf('Trash')).data, '1');
    expect(find.text('Cards'), findsNothing);
    expect(find.text('Old bank'), findsNothing);

    await tester.tap(find.text('Trash'));
    await settle(tester);
    expect(find.text('Trash'), findsNWidgets(2));
    expect(find.text('GitHub'), findsNothing);
    await tester.tap(find.text('Old bank'));
    await settle(tester);
    expect(find.text('Old bank'), findsNWidgets(2));
    expect(find.text('alice'), findsNWidgets(2));
    await close(tester);
  });

  testWidgets('leaves the filter column out below a desktop width', (
    tester,
  ) async {
    setScreen(tester, const Size(900, 800));
    await open(tester, items: [github]);
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    expect(find.text('Favorites'), findsNothing);
    expect(find.text('All vaults'), findsOneWidget);
    expect(find.byTooltip('Sync now'), findsOneWidget);
    await close(tester);
  });

  testWidgets('searches the items from Ctrl+F on a desktop', (tester) async {
    setScreen(tester, const Size(1280, 800));
    await open(
      tester,
      items: [
        github,
        Cipher(
          type: CipherType.secureNote,
          name: 'Alarm code',
          secureNote: SecureNote(),
        ),
      ],
    );
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    expect(find.text('Search 2 items'), findsOneWidget);
    expect(find.text('Ctrl+F'), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );

    await tester.enterText(find.byType(TextField), 'alarm');
    await settle(tester);
    expect(find.text('Alarm code'), findsOneWidget);
    expect(find.text('GitHub'), findsNothing);
    expect(find.text('Ctrl+F'), findsNothing);

    await tester.enterText(find.byType(TextField), 'bank');
    await settle(tester);
    expect(find.text('No items match your search.'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear the search'));
    await settle(tester);
    expect(find.text('Alarm code'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'github.com');
    await settle(tester);
    await tester.tap(find.text('GitHub'));
    await settle(tester);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Alarm code'), findsNothing);

    await tester.tap(find.byType(TextField));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);
    expect(find.text('Alarm code'), findsOneWidget);
    expect(find.text('github.com'), findsNothing);
    await close(tester);
  });

  testWidgets('keeps the search on a phone, back from an item', (tester) async {
    setScreen(tester, const Size(390, 844), locale: const Locale('fr'));
    await open(
      tester,
      items: [
        github,
        Cipher(
          type: CipherType.secureNote,
          name: 'Alarm code',
          secureNote: SecureNote(),
        ),
      ],
    );
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    expect(find.text('Rechercher parmi 2 éléments'), findsOneWidget);
    expect(find.text('Ctrl+F'), findsNothing);
    await tester.enterText(find.byType(TextField), 'git');
    await settle(tester);
    expect(find.text('Alarm code'), findsNothing);
    await tester.tap(find.text('GitHub'));
    await settle(tester);
    expect(find.text('Nom d\'utilisateur'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(find.text('git'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Alarm code'), findsNothing);
    await close(tester);
  });

  testWidgets('keeps the items in place from all vaults to one vault', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, items: [github], withFamily: true);
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    expect(find.text('All vaults'), findsOneWidget);
    final withBadge = tester.getRect(find.text('GitHub'));
    await tester.tap(find.byTooltip('Personal'));
    await settle(tester);

    expect(find.text('All vaults'), findsNothing);
    expect(tester.getRect(find.text('GitHub')), withBadge);
    await close(tester);
  });
}
