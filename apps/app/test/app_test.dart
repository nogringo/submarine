import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast_memory.dart' show newDatabaseFactoryMemory;
import 'package:submarine/src/app.dart';
import 'package:submarine/src/items/field_tile.dart';
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

  bool saveEnabled(WidgetTester tester) => tester
      .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
      .enabled;

  /// Taps [button], whose write needs real time to reach the cache.
  Future<void> write(WidgetTester tester, Finder button) async {
    await tester.pump();
    await tester.runAsync(() async {
      await tester.tap(button);
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await settle(tester);
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

  testWidgets('keeps the item open in the lists that hold it on a desktop', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(
      tester,
      items: [
        Cipher(
          type: CipherType.login,
          name: 'GitHub',
          favorite: true,
          login: Login(username: 'alice-dev'),
        ),
        Cipher(
          type: CipherType.secureNote,
          name: 'Alarm code',
          secureNote: SecureNote(),
        ),
      ],
      withFamily: true,
    );
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    await tester.tap(find.text('GitHub'));
    await settle(tester);
    await tester.tap(find.text('Favorites'));
    await settle(tester);
    expect(find.text('alice-dev'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Personal'));
    await settle(tester);
    expect(find.text('alice-dev'), findsNWidgets(2));
    await tester.tap(find.text('Secure notes'));
    await settle(tester);
    expect(find.text('Select an item to see it here.'), findsOneWidget);

    await tester.tap(find.text('All items'));
    await settle(tester);
    await tester.tap(find.text('GitHub'));
    await settle(tester);
    await tester.tap(find.byTooltip('Family'));
    await settle(tester);
    expect(find.text('Select an item to see it here.'), findsOneWidget);
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

  testWidgets('creates a login in the vault of choice on a desktop', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, items: [github], withFamily: true);
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    await tester.tap(find.text('New item'));
    await settle(tester);
    expect(find.text('New login'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);
    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'bob');
    await write(tester, find.text('Save'));
    expect(find.text('Give the item a name.'), findsOneWidget);

    await tester.tap(find.text('Personal'));
    await settle(tester);
    await tester.tap(find.text('Family').last);
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Netflix');
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'hunter2',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Website'),
      'netflix.com',
    );
    await write(tester, find.text('Save'));

    expect(find.text('Netflix'), findsNWidgets(2));
    expect(find.text('Username'), findsOneWidget);
    final [item] = (await tester.runAsync(vaults.all.last.vault.items))!;
    expect(item.cipher.name, 'Netflix');
    expect(item.cipher.login!.username, 'bob');
    expect(item.cipher.login!.password, 'hunter2');
    expect(item.cipher.login!.uris.single.uri, 'netflix.com');
    await close(tester);
  });

  testWidgets('edits a login, and keeps what the form leaves out', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(
      tester,
      items: [
        Cipher(
          type: CipherType.login,
          name: 'GitHub',
          notes: 'Recovery codes are in the safe.',
          login: Login(
            uris: [
              LoginUri('https://github.com', match: UriMatchStrategy.host),
            ],
            username: 'alice-dev',
            password: 'Tr0ub4dor&3',
          ),
          fields: [Field(name: 'PIN', value: '1234')],
        ),
      ],
    );
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    await tester.tap(find.text('GitHub'));
    await settle(tester);
    await tester.tap(find.text('Edit'));
    await settle(tester);
    expect(find.text('Edit item'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);
    await tester.tap(find.text('Add a website'));
    await settle(tester);
    expect(saveEnabled(tester), isFalse);
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'correct horse',
    );
    await tester.pump();
    expect(saveEnabled(tester), isTrue);
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'Tr0ub4dor&3',
    );
    await tester.pump();
    expect(saveEnabled(tester), isFalse);
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'correct horse',
    );
    await write(tester, find.text('Save'));

    expect(find.text('Password history'), findsOneWidget);
    final [item] = (await tester.runAsync(vaults.all.single.vault.items))!;
    expect(item.hasConflict, isFalse);
    final cipher = item.cipher;
    expect(cipher.login!.password, 'correct horse');
    expect(cipher.passwordHistory.single.password, 'Tr0ub4dor&3');
    expect(cipher.login!.uris.single.match, UriMatchStrategy.host);
    expect(cipher.fields.single.value, '1234');
    expect(cipher.notes, 'Recovery codes are in the safe.');
    await close(tester);
  });

  testWidgets('asks before another item drops an edit on a desktop', (
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
      ],
    );
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    await tester.tap(find.text('GitHub'));
    await settle(tester);
    await tester.tap(find.text('Edit'));
    await settle(tester);
    await tester.tap(find.text('Alarm code'));
    await settle(tester);
    expect(find.text('Discard your changes?'), findsNothing);
    expect(find.text('Alarm code'), findsNWidgets(2));

    await tester.tap(find.text('GitHub'));
    await settle(tester);
    await tester.tap(find.text('Edit'));
    await settle(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'correct horse',
    );
    await tester.tap(find.text('Alarm code'));
    await settle(tester);
    expect(find.text('Discard your changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await settle(tester);
    expect(find.text('Edit item'), findsOneWidget);
    expect(find.text('correct horse'), findsOneWidget);

    await tester.tap(find.text('Alarm code'));
    await settle(tester);
    await tester.tap(find.text('Discard'));
    await settle(tester);
    expect(find.text('Edit item'), findsNothing);
    expect(find.text('Alarm code'), findsNWidgets(2));
    final items = (await tester.runAsync(vaults.all.single.vault.items))!;
    final saved = items.singleWhere((item) => item.cipher.name == 'GitHub');
    expect(saved.cipher.login!.password, 'Tr0ub4dor&3');

    await tester.tap(find.text('GitHub'));
    await settle(tester);
    await tester.tap(find.text('Edit'));
    await settle(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'correct horse',
    );
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Discard your changes?'), findsNothing);
    expect(find.text('Edit item'), findsNothing);
    await close(tester);
  });

  testWidgets('asks before the back button drops an edit on a phone', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844), locale: const Locale('fr'));
    await open(tester, items: [github]);
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    await tester.tap(find.text('GitHub'));
    await settle(tester);
    await tester.tap(find.text('Modifier'));
    await settle(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Mot de passe'),
      'correct horse',
    );
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.text('Abandonner vos modifications ?'), findsOneWidget);
    await tester.tap(find.text('Continuer la modification'));
    await settle(tester);
    expect(find.text('Modifier l\'élément'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await settle(tester);
    await tester.tap(find.text('Abandonner'));
    await settle(tester);
    expect(find.text('Modifier l\'élément'), findsNothing);
    expect(find.text('Modifier'), findsOneWidget);
    await close(tester);
  });

  testWidgets('keeps a copied password out of the preview of Android', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    final messenger = tester.binding.defaultBinaryMessenger;
    const clipboard = MethodChannel('submarine/clipboard');
    final sensitive = <Object?>[];
    final plain = <Object?>[];
    messenger
      ..setMockMethodCallHandler(clipboard, (call) async {
        sensitive.add(call.arguments);
        return null;
      })
      ..setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          plain.add((call.arguments as Map)['text']);
        }
        return null;
      });
    addTearDown(() {
      messenger
        ..setMockMethodCallHandler(clipboard, null)
        ..setMockMethodCallHandler(SystemChannels.platform, null);
    });
    await open(tester, items: [github]);
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);
    Finder copyOf(String label) => find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(FieldTile)),
      matching: find.byTooltip('Copy'),
    );

    await tester.tap(find.text('GitHub'));
    await settle(tester);
    await tester.tap(copyOf('Password'));
    await tester.tap(copyOf('Username'));
    await settle(tester);

    expect(sensitive, ['Tr0ub4dor&3']);
    expect(plain, ['alice-dev']);
    await close(tester);
  });

  testWidgets('marks an item as a favorite', (tester) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, items: [github]);
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    await tester.tap(find.text('GitHub'));
    await settle(tester);
    await write(tester, find.byTooltip('Add to favorites'));

    expect(find.byTooltip('Remove from favorites'), findsOneWidget);
    await tester.tap(find.text('Favorites'));
    await settle(tester);
    expect(find.text('GitHub'), findsNWidgets(2));
    await close(tester);
  });

  testWidgets('creates a login on a phone, in French', (tester) async {
    setScreen(tester, const Size(390, 844), locale: const Locale('fr'));
    await open(tester, items: [github]);
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    await tester.tap(find.byTooltip('Nouvel élément'));
    await settle(tester);
    expect(find.text('Nouvel identifiant'), findsOneWidget);
    expect(find.text('Coffre'), findsNothing);
    await tester.enterText(find.widgetWithText(TextField, 'Nom'), 'Netflix');
    await write(tester, find.text('Enregistrer'));

    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Modifier'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
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

  Finder nsecText() => find.byWidgetPredicate(
    (widget) =>
        widget is SelectableText && (widget.data?.startsWith('nsec1') ?? false),
  );

  testWidgets('shows the key of a vault in its settings on a phone', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844), locale: const Locale('fr'));
    await open(tester, withFamily: true);
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);

    await tester.tap(find.byTooltip('Coffres'));
    await settle(tester);
    await tester.tap(find.byTooltip('Réglages du coffre'));
    await settle(tester);

    expect(find.text('Réglages du coffre'), findsOneWidget);
    expect(nsecText(), findsNothing);
    await tester.tap(find.text('Afficher'));
    await settle(tester);
    final nsec = tester.widget<SelectableText>(nsecText());
    expect(parseVaultKey(nsec.data!), vaults.all.single.record.privateKey);

    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(find.text('Réglages du coffre'), findsNothing);
    expect(find.text('Tous les coffres'), findsOneWidget);
    await close(tester);
  });

  testWidgets('renames and recolors a vault in its settings on a desktop', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, withFamily: true);
    await tester.pumpWidget(SubmarineApp(vaults: vaults));
    await settle(tester);
    Future<Map<String, dynamic>> saved() async =>
        (jsonDecode(
              (await const FlutterSecureStorage().read(key: 'vaults'))!,
            ) as List).single
            as Map<String, dynamic>;

    await tester.tap(find.byTooltip('Family'));
    await settle(tester);
    await tester.tap(find.byTooltip('Vault settings'));
    await settle(tester);
    expect(find.text('Vault settings'), findsOneWidget);

    await tester.runAsync(() async {
      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Home');
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await settle(tester);
    expect(find.byTooltip('Home'), findsOneWidget);
    expect((await saved())['name'], 'Home');

    await write(
      tester,
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Color 3',
      ),
    );
    expect((await saved())['color'], vaultColors[2].toARGB32());

    await tester.enterText(find.widgetWithText(TextField, 'Name'), ' ');
    await settle(tester);
    expect(find.text('Give the vault a name.'), findsOneWidget);
    expect((await saved())['name'], 'Home');

    await tester.tap(find.byTooltip('Home'));
    await settle(tester);
    expect(find.text('Vault settings'), findsNothing);
    expect(find.text('Home'), findsOneWidget);
    await close(tester);
  });
}
