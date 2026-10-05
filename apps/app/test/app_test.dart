import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:flutter_test/flutter_test.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast_memory.dart' show newDatabaseFactoryMemory;
import 'package:submarine/src/app.dart';
import 'package:submarine/src/clipboard.dart';
import 'package:submarine/src/generator/generator_settings.dart';
import 'package:submarine/src/items/field_tile.dart';
import 'package:submarine/src/lock/app_lock.dart';
import 'package:submarine/src/screen_capture.dart';
import 'package:submarine/src/screens/filter_column.dart';
import 'package:submarine/src/storage_error_app.dart';
import 'package:submarine/src/theme/appearance.dart';
import 'package:submarine/src/vaults/vault_storage.dart';
import 'package:submarine/src/vaults/vaults.dart';
import 'package:submarine/src/widgets/copy_button.dart';
import 'package:submarine/src/widgets/settings_tile.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

void main() {
  late Ndk ndk;
  late Vaults vaults;
  late AppLock lock;
  late FakeDeviceAuth deviceAuth;
  late Appearance appearance;
  late AppClipboard clipboard;
  late ScreenCapture screenCapture;

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
  /// [withFamily]. The app locks as [lockSettings] say, behind a device that
  /// lets the user in until told otherwise.
  Future<void> open(
    WidgetTester tester, {
    List<Cipher> items = const [],
    bool withFamily = false,
    LockSettings? lockSettings,
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
      if (lockSettings != null) 'lock': jsonEncode(lockSettings.toJson()),
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
    lock = await AppLock.load(auth: deviceAuth = FakeDeviceAuth());
    appearance = await Appearance.load();
    clipboard = await AppClipboard.load();
    screenCapture = await ScreenCapture.load();
  });

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    lock.dispose();
    appearance.dispose();
    clipboard.dispose();
    screenCapture.dispose();
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

  /// [text] in the open dialog, not on the screen behind it.
  Finder inDialog(String text) =>
      find.descendant(of: find.byType(Dialog), matching: find.text(text));

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

  /// Taps [button], then lets its work run in real time, frames in between,
  /// until [done]: deriving the key of a file password takes an isolate.
  Future<void> tapUntil(
    WidgetTester tester,
    Finder button,
    bool Function() done,
  ) async {
    await tester.pump();
    await tester.runAsync(() async => tester.tap(button));
    for (var i = 0; i < 100 && !done(); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    await settle(tester);
  }

  /// Opens the menu of [button] in real time, where the callback of its items
  /// gets registered, so that they write in real time too.
  Future<void> openMenu(WidgetTester tester, Finder button) =>
      write(tester, button);

  /// What the app copies, through the clipboard of Android in tests.
  List<Object?> watchClipboard(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
    const channel = MethodChannel('submarine/clipboard');
    final copies = <Object?>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      copies.add(call.arguments);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    return copies;
  }

  Finder settingsSwitch(String title) => find.descendant(
    of: find.widgetWithText(SettingsTile, title),
    matching: find.byType(Switch),
  );

  /// Opens the menu of the row of [name] in real time, as [openMenu] does,
  /// from a right click or else a long press.
  Future<void> openRowMenu(
    WidgetTester tester,
    String name, {
    bool longPress = false,
  }) async {
    final row = find.descendant(
      of: find.byType(ListView),
      matching: find.text(name),
    );
    await tester.pump();
    await tester.runAsync(() async {
      if (longPress) {
        final gesture = await tester.startGesture(tester.getCenter(row));
        await Future<void>.delayed(
          kLongPressTimeout + const Duration(milliseconds: 100),
        );
        await gesture.up();
      } else {
        await tester.tap(row, buttons: kSecondaryButton);
      }
    });
    await settle(tester);
  }

  testWidgets('welcomes a device without vaults, then creates one', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844));
    await open(tester);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);

    expect(find.byType(FilterColumn), findsNothing);
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
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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

  testWidgets(
    'keeps a copied password out of the preview of Android, and clears it',
    (tester) async {
      setScreen(tester, const Size(1280, 800));
      final copies = watchClipboard(tester);
      await open(tester, items: [github]);
      await tester.pumpWidget(
        SubmarineApp(
          vaults: vaults,
          lock: lock,
          appearance: appearance,
          clipboard: clipboard,
          screenCapture: screenCapture,
        ),
      );
      await settle(tester);
      Finder copyOf(String label) => find.descendant(
        of: find.ancestor(
          of: find.text(label),
          matching: find.byType(FieldTile),
        ),
        matching: find.byTooltip('Copy'),
      );

      await tester.tap(find.text('GitHub'));
      await settle(tester);
      await tester.tap(copyOf('Password'));
      await tester.tap(copyOf('Username'));
      await settle(tester);

      expect(copies, [
        {'text': 'Tr0ub4dor&3', 'sensitive': true, 'clearAfter': 30000},
        {'text': 'alice-dev', 'sensitive': false, 'clearAfter': null},
      ]);
      await close(tester);
    },
  );

  testWidgets('moves an item to the trash and back on a desktop', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, items: [github]);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);

    await tester.tap(find.text('GitHub'));
    await settle(tester);
    await openMenu(tester, find.byTooltip('More actions'));
    await write(tester, find.text('Move to trash'));

    expect(find.text('GitHub'), findsNothing);
    expect(find.text('Select an item to see it here.'), findsOneWidget);
    await tester.tap(find.text('Trash'));
    await settle(tester);
    await tester.tap(find.text('GitHub'));
    await settle(tester);
    expect(find.text('Edit'), findsNothing);
    await write(tester, find.text('Restore'));

    expect(find.text('GitHub'), findsNothing);
    await tester.tap(find.text('All items'));
    await settle(tester);
    expect(find.text('GitHub'), findsOneWidget);
    expect(vaults.all.single.items.single.cipher.isDeleted, isFalse);
    await close(tester);
  });

  testWidgets('deletes an item in the trash for good', (tester) async {
    setScreen(tester, const Size(1280, 800));
    await open(
      tester,
      items: [
        Cipher.fromJson(github.toJson())..deletedDate = DateTime.utc(2026, 10),
      ],
    );
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);

    await tester.tap(find.text('Trash'));
    await settle(tester);
    await tester.tap(find.text('GitHub'));
    await settle(tester);
    await openMenu(tester, find.byTooltip('More actions'));
    await write(tester, find.text('Delete permanently'));
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(vaults.all.single.items, hasLength(1));

    await openMenu(tester, find.byTooltip('More actions'));
    await write(tester, find.text('Delete permanently'));
    expect(find.text('Delete this item permanently?'), findsOneWidget);
    await write(tester, find.text('Delete'));

    expect(find.text('GitHub'), findsNothing);
    expect(vaults.all.single.items, isEmpty);
    await close(tester);
  });

  testWidgets('moves an item to the trash and back on a phone, in French', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844), locale: const Locale('fr'));
    await open(tester, items: [github]);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);

    await tester.tap(find.text('GitHub'));
    await settle(tester);
    await openMenu(tester, find.byTooltip('Plus d\'actions'));
    await write(tester, find.text('Mettre à la corbeille'));

    expect(find.text('Tous les coffres'), findsOneWidget);
    expect(find.text('GitHub'), findsNothing);
    await tester.tap(find.text('Corbeille'));
    await settle(tester);
    await tester.tap(find.text('GitHub'));
    await settle(tester);
    await write(tester, find.text('Restaurer'));

    expect(find.text('GitHub'), findsNothing);
    await tester.tap(find.text('Tous'));
    await settle(tester);
    expect(find.text('GitHub'), findsOneWidget);
    await close(tester);
  });

  testWidgets('trashes and deletes an item from its row on a desktop', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, items: [github]);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);

    await tester.tap(find.text('GitHub'));
    await settle(tester);
    await openRowMenu(tester, 'GitHub');
    expect(find.text('Add to favorites'), findsOneWidget);
    expect(find.text('Copy verification code'), findsNothing);
    await write(tester, find.text('Move to trash'));

    expect(find.text('GitHub'), findsNothing);
    expect(find.text('Select an item to see it here.'), findsOneWidget);
    await tester.tap(find.text('Trash'));
    await settle(tester);
    await openRowMenu(tester, 'GitHub');
    expect(find.text('Move to trash'), findsNothing);
    await write(tester, find.text('Delete permanently'));
    expect(find.text('Delete this item permanently?'), findsOneWidget);
    await write(tester, find.text('Delete'));

    expect(find.text('GitHub'), findsNothing);
    expect(vaults.all.single.items, isEmpty);
    await close(tester);
  });

  testWidgets('trashes and restores an item from its row on a phone', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844), locale: const Locale('fr'));
    await open(tester, items: [github]);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);

    await openRowMenu(tester, 'GitHub', longPress: true);
    await write(tester, find.text('Mettre à la corbeille'));

    expect(find.text('Tous les coffres'), findsOneWidget);
    expect(find.text('GitHub'), findsNothing);
    await tester.tap(find.text('Corbeille'));
    await settle(tester);
    await openRowMenu(tester, 'GitHub', longPress: true);
    await write(tester, find.text('Restaurer'));

    expect(find.text('GitHub'), findsNothing);
    await tester.tap(find.text('Tous'));
    await settle(tester);
    expect(find.text('GitHub'), findsOneWidget);
    await close(tester);
  });

  testWidgets('copies the username, the password and the code from a row', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    final copies = watchClipboard(tester);
    await open(
      tester,
      items: [
        Cipher.fromJson(github.toJson())..login!.totp = 'JBSWY3DPEHPK3PXP',
      ],
    );
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);
    expect(find.byType(CopyButton), findsNothing);

    for (final copy in [
      'Copy username',
      'Copy password',
      'Copy verification code',
    ]) {
      await openRowMenu(tester, 'GitHub');
      await write(tester, find.text(copy));
    }

    expect(copies, [
      {'text': 'alice-dev', 'sensitive': false, 'clearAfter': null},
      {'text': 'Tr0ub4dor&3', 'sensitive': true, 'clearAfter': 30000},
      {
        'text': matches(RegExp(r'^\d{6}$')),
        'sensitive': true,
        'clearAfter': 30000,
      },
    ]);
    expect(find.text('Select an item to see it here.'), findsOneWidget);
    await close(tester);
  });

  testWidgets('copies the password or the card number from a row on a phone', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844));
    final copies = watchClipboard(tester);
    await open(
      tester,
      items: [
        github,
        Cipher(
          type: CipherType.card,
          name: 'Joint account card',
          card: PaymentCard(brand: 'Mastercard', number: '5555555555554444'),
        ),
        Cipher(type: CipherType.secureNote, name: 'Alarm code', notes: '1234'),
      ],
    );
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);
    expect(find.text('Alarm code'), findsOneWidget);
    expect(find.byType(CopyButton), findsNWidgets(2));

    await write(tester, find.byTooltip('Copy password'));
    await write(tester, find.byTooltip('Copy number'));

    expect(copies, [
      {'text': 'Tr0ub4dor&3', 'sensitive': true, 'clearAfter': 30000},
      {'text': '5555555555554444', 'sensitive': true, 'clearAfter': 30000},
    ]);
    await close(tester);
  });

  testWidgets('marks an item as a favorite', (tester) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, items: [github]);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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

  testWidgets('generates a password with the options of its sheet', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844));
    await open(tester, items: [github]);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);

    String generated() =>
        tester.widget<PasswordText>(find.byType(PasswordText)).value;
    Future<void> tapInSheet(Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await settle(tester);
    }

    await tester.tap(find.byTooltip('New item'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Netflix');
    await tester.tap(find.byTooltip('Generate a password'));
    await settle(tester);
    expect(find.text('Generator'), findsOneWidget);
    expect(generated(), matches(RegExp(r'^[A-Za-z0-9]{14}$')));

    await tapInSheet(find.text(r'!@#$%^&*'));
    await tapInSheet(find.byTooltip('Increase').first);
    final password = generated();
    expect(password, hasLength(15));
    expect(password, contains(RegExp(r'[!@#$%^&*]')));
    await tapInSheet(find.text('Use this password'));
    expect(find.text('Generator'), findsNothing);
    expect(
      tester
          .widget<TextField>(find.widgetWithText(TextField, 'Password'))
          .controller!
          .text,
      password,
    );
    await write(tester, find.text('Save'));
    final items = (await tester.runAsync(vaults.all.single.vault.items))!;
    final netflix = items.singleWhere((item) => item.cipher.name == 'Netflix');
    expect(netflix.cipher.login!.password, password);

    await tester.tap(find.text('Edit'));
    await settle(tester);
    await tester.tap(find.byTooltip('Generate a password'));
    await settle(tester);
    expect(generated(), hasLength(15));
    expect(generated(), contains(RegExp(r'[!@#$%^&*]')));
    await tapInSheet(find.text('Passphrase'));
    expect(generated().split('-'), hasLength(6));
    await tapInSheet(find.text('Use this passphrase'));
    expect(saveEnabled(tester), isTrue);
    await close(tester);
  });

  testWidgets('keeps the items in place from all vaults to one vault', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, items: [github], withFamily: true);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
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

  testWidgets('lists the vaults in the settings on a phone, in French', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844), locale: const Locale('fr'));
    await open(tester, items: [github], withFamily: true);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);

    await tester.tap(find.text('Réglages'));
    await settle(tester);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Family'), findsOneWidget);
    expect(
      find.text(Nip19.encodePubKey(vaults.all.last.pubkey)),
      findsOneWidget,
    );

    await tester.tap(find.text('Family'));
    await settle(tester);
    expect(find.text('Réglages du coffre'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(find.text('Réglages du coffre'), findsNothing);
    expect(find.text('Sécurité'), findsOneWidget);

    await tester.tap(find.text('Ajouter un coffre'));
    await settle(tester);
    expect(find.text('Créer un coffre'), findsOneWidget);
    await close(tester);
  });

  testWidgets('imports a Bitwarden export into the vault of choice', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, items: [github], withFamily: true);
    FilePickerPlatform.instance = FakeFilePicker()
      ..picked = FakeFile(
        'bitwarden_export.json',
        jsonEncode({
          'encrypted': false,
          'folders': [],
          'items': [
            {
              'id': 'bitwarden-id',
              'organizationId': null,
              'folderId': null,
              'type': 1,
              'name': 'Freebox',
              'login': {'username': 'freebox', 'password': 'hunter2'},
              'collectionIds': null,
            },
            {
              'type': 2,
              'name': 'Alarm code',
              'notes': '1234',
              'secureNote': {'type': 0},
            },
          ],
        }),
      );
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    await tester.ensureVisible(find.text('Import'));
    await settle(tester);

    await write(tester, find.text('Import'));
    expect(
      find.text('2 items found in bitwarden_export.json.'),
      findsOneWidget,
    );
    await tester.tap(inDialog('Personal'));
    await settle(tester);
    await tester.tap(find.text('Family').last);
    await settle(tester);
    final family = vaults.all.last;
    await tester.runAsync(() async {
      await tester.tap(find.widgetWithText(FilledButton, 'Import'));
      while (family.items.length < 2) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await settle(tester);

    expect(find.text('2 items imported into Family.'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await settle(tester);
    expect(find.text('2 items imported into Family.'), findsNothing);
    expect(
      [for (final item in family.items) item.cipher.name],
      ['Alarm code', 'Freebox'],
    );
    expect(family.items.last.cipher.login!.password, 'hunter2');
    expect(family.items.last.cipher.toJson(), isNot(contains('id')));
    expect(vaults.all.first.items, hasLength(1));
    await close(tester);
  });

  testWidgets('says why a file cannot be imported, in French', (tester) async {
    setScreen(tester, const Size(390, 844), locale: const Locale('fr'));
    await open(tester, items: [github]);
    final picker = FakeFilePicker();
    FilePickerPlatform.instance = picker;
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);
    await tester.tap(find.text('Réglages'));
    await settle(tester);
    await tester.ensureVisible(find.text('Importer'));
    await settle(tester);
    const encrypted =
        "Cet export est restreint à votre compte Bitwarden, et seul Bitwarden "
        "peut l'ouvrir. Exportez à nouveau votre coffre depuis Bitwarden, "
        'protégé par mot de passe ou au format .json.';

    picker.picked = FakeFile(
      'bitwarden_encrypted_export.json',
      jsonEncode({
        'encrypted': true,
        'encKeyValidation_DO_NOT_EDIT': '2.abc|def|ghi',
        'folders': [],
        'items': [],
      }),
    );
    await write(tester, find.text('Importer'));
    expect(find.text(encrypted), findsOneWidget);

    picker.picked = FakeFile('passwords.json', 'name,url,username,password');
    await write(tester, find.text('Importer'));
    expect(find.text(encrypted), findsNothing);
    expect(
      find.text("Ce fichier n'est pas un export JSON de Bitwarden."),
      findsOneWidget,
    );
    expect(vaults.all.single.items, hasLength(1));
    await close(tester);
  });

  testWidgets('exports a vault of choice, without its trash', (tester) async {
    setScreen(tester, const Size(1280, 800));
    await open(
      tester,
      items: [
        github,
        Cipher(
          type: CipherType.secureNote,
          name: 'Old note',
          deletedDate: DateTime.utc(2026, 10),
        ),
      ],
      withFamily: true,
    );
    final picker = FakeFilePicker();
    FilePickerPlatform.instance = picker;
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    await tester.ensureVisible(find.text('Export'));
    await settle(tester);
    bool exportEnabled() => tester
        .widget<FilledButton>(find.widgetWithText(FilledButton, 'Export'))
        .enabled;

    await tester.tap(find.text('Export'));
    await settle(tester);
    expect(find.text('1 item. The trash is left out.'), findsOneWidget);
    await tester.tap(inDialog('Personal'));
    await settle(tester);
    await tester.tap(find.text('Family').last);
    await settle(tester);
    expect(find.text('This vault has no items to export.'), findsOneWidget);
    expect(exportEnabled(), isFalse);

    await tester.tap(inDialog('Family'));
    await settle(tester);
    await tester.tap(find.text('Personal').last);
    await settle(tester);
    expect(exportEnabled(), isTrue);
    await tester.tap(
      find.descendant(of: find.byType(Dialog), matching: find.byType(Switch)),
    );
    await settle(tester);
    expect(find.widgetWithText(TextField, 'File password'), findsNothing);
    expect(
      find.text(
        'The file is not encrypted. Do not send it by email, and delete it '
        'once you are done with it.',
      ),
      findsOneWidget,
    );
    await write(tester, find.widgetWithText(FilledButton, 'Export'));

    expect(find.text('1 item. The trash is left out.'), findsNothing);
    expect(
      picker.savedName,
      matches(RegExp(r'^submarine_export_\d{14}\.json$')),
    );
    final [cipher] = parseBitwardenExport(utf8.decode(picker.savedBytes!));
    expect(cipher.name, 'GitHub');
    expect(cipher.login!.password, 'Tr0ub4dor&3');
    await close(tester);
  });

  testWidgets('exports a vault protected by a password, then imports it', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, items: [github], withFamily: true);
    final picker = FakeFilePicker();
    FilePickerPlatform.instance = picker;
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    await tester.ensureVisible(find.text('Export'));
    await settle(tester);
    final exportButton = find.widgetWithText(FilledButton, 'Export');
    final filePassword = find.widgetWithText(TextField, 'File password');
    final confirmation = find.widgetWithText(
      TextField,
      'Confirm the file password',
    );
    final openButton = find.widgetWithText(FilledButton, 'Open');
    const wrongPassword = 'This password does not open the file.';

    await tester.tap(find.text('Export'));
    await settle(tester);
    await tester.tap(exportButton);
    await settle(tester);
    expect(find.text('Choose a password.'), findsOneWidget);
    await tester.enterText(filePassword, 'hunter2');
    await tester.enterText(confirmation, 'hunter3');
    await tester.tap(exportButton);
    await settle(tester);
    expect(find.text('The passwords do not match.'), findsOneWidget);
    await tester.enterText(confirmation, 'hunter2');
    await tapUntil(tester, exportButton, () => picker.savedBytes != null);

    expect(
      picker.savedName,
      matches(RegExp(r'^submarine_encrypted_export_\d{14}\.json$')),
    );
    final saved = utf8.decode(picker.savedBytes!);
    expect(jsonDecode(saved), containsPair('passwordProtected', true));
    expect(saved, isNot(contains('Tr0ub4dor&3')));

    picker.picked = FakeFile(picker.savedName!, saved);
    await write(tester, find.text('Import'));
    expect(
      find.text(
        'This export is protected by a password. Enter it to open the file.',
      ),
      findsOneWidget,
    );
    await tester.enterText(filePassword, 'hunter3');
    await tapUntil(
      tester,
      openButton,
      () => find.text(wrongPassword).evaluate().isNotEmpty,
    );
    expect(find.text(wrongPassword), findsOneWidget);
    await tester.enterText(filePassword, 'hunter2');
    await tapUntil(
      tester,
      openButton,
      () => find.textContaining('found in').evaluate().isNotEmpty,
    );
    expect(find.text('1 item found in ${picker.savedName}.'), findsOneWidget);

    await tester.tap(inDialog('Personal'));
    await settle(tester);
    await tester.tap(find.text('Family').last);
    await settle(tester);
    final family = vaults.all.last;
    await tapUntil(
      tester,
      find.widgetWithText(FilledButton, 'Import'),
      () => family.items.isNotEmpty,
    );
    expect(find.text('1 item imported into Family.'), findsOneWidget);
    expect(family.items.single.cipher.login!.password, 'Tr0ub4dor&3');
    await close(tester);
  });

  testWidgets('turns the lock on in the settings, then locks from the rail', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, items: [github]);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);
    expect(find.byTooltip('Lock'), findsNothing);

    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    expect(find.text('Lock after'), findsNothing);
    await tester.tap(settingsSwitch('Unlock with biometrics'));
    await settle(tester);
    expect(deviceAuth.asked, 1);
    expect(find.text('5 minutes'), findsOneWidget);
    expect((await LockSettings.read()).enabled, isTrue);

    await tester.tap(find.byTooltip('Lock'));
    await settle(tester);
    expect(deviceAuth.asked, 1);
    expect(find.text('Your vaults are locked.'), findsOneWidget);
    expect(find.text('Security'), findsNothing);

    await tester.tap(find.text('Unlock'));
    await settle(tester);
    expect(find.text('Your vaults are locked.'), findsNothing);
    expect(find.text('Security'), findsOneWidget);

    await tester.tap(settingsSwitch('Unlock with biometrics'));
    await settle(tester);
    expect(find.byTooltip('Lock'), findsNothing);
    expect((await LockSettings.read()).enabled, isFalse);
    await close(tester);
  });

  testWidgets('keeps the lock off on a device without a screen lock', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, items: [github]);
    deviceAuth.available = false;
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);

    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    expect(
      tester.widget<Switch>(settingsSwitch('Unlock with biometrics')).onChanged,
      isNull,
    );
    expect(
      find.text('Set up a screen lock on this device first.'),
      findsOneWidget,
    );
    await close(tester);
  });

  testWidgets('locks after five minutes without use, and asks only on a tap', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(
      tester,
      items: [github],
      lockSettings: const LockSettings(enabled: true),
    );
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);
    expect(find.text('Your vaults are locked.'), findsOneWidget);
    expect(find.text('GitHub'), findsNothing);
    expect(deviceAuth.asked, 0);

    await tester.tap(find.text('Unlock'));
    await settle(tester);
    expect(find.text('GitHub'), findsOneWidget);

    await tester.pump(const Duration(minutes: 4));
    await tester.tap(find.text('GitHub'));
    await tester.pump(const Duration(minutes: 4));
    expect(find.text('Your vaults are locked.'), findsNothing);

    // The user works in another app, then focuses the window back.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(const Duration(minutes: 1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester);
    expect(find.text('Your vaults are locked.'), findsOneWidget);
    expect(deviceAuth.asked, 1);
    await close(tester);
  });

  testWidgets('locks as soon as it leaves the screen on a phone, in French', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844), locale: const Locale('fr'));
    await open(
      tester,
      items: [github],
      lockSettings: const LockSettings(
        enabled: true,
        timeout: LockTimeout.immediately,
      ),
    );
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);
    await tester.tap(find.text('Déverrouiller'));
    await settle(tester);
    expect(find.text('GitHub'), findsOneWidget);

    await tester.tap(find.byTooltip('Verrouiller'));
    await settle(tester);
    expect(find.text('Vos coffres sont verrouillés.'), findsOneWidget);

    await tester.tap(find.text('Déverrouiller'));
    await settle(tester);
    expect(find.text('GitHub'), findsOneWidget);

    void moveTo(List<AppLifecycleState> states) {
      for (final state in states) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
    }

    final asked = deviceAuth.asked;
    moveTo([AppLifecycleState.inactive, AppLifecycleState.hidden]);
    // No frame gets drawn while the app is hidden.
    expect(lock.locked, isTrue);
    moveTo([AppLifecycleState.inactive, AppLifecycleState.resumed]);
    await settle(tester);
    expect(find.text('Vos coffres sont verrouillés.'), findsOneWidget);
    expect(deviceAuth.asked, asked);
    await close(tester);
  });

  testWidgets('switches to the dark theme in the settings, and keeps it', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, items: [github]);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);
    Brightness brightness() =>
        Theme.of(tester.element(find.text('Theme'))).brightness;

    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    expect(brightness(), Brightness.light);

    await tester.tap(find.text('Dark'));
    await settle(tester);
    expect(brightness(), Brightness.dark);
    await tester.runAsync(() async {
      expect((await Appearance.load()).themeMode, ThemeMode.dark);
    });

    await tester.tap(find.text('System'));
    await settle(tester);
    expect(brightness(), Brightness.light);
    await close(tester);
  });

  testWidgets('blocks screen capture until the settings allow it', (
    tester,
  ) async {
    setScreen(tester, const Size(1280, 800));
    final messenger = tester.binding.defaultBinaryMessenger;
    const channel = MethodChannel('submarine/screen_capture');
    final allowed = <Object?>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      allowed.add(call.arguments);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await open(tester, items: [github]);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);
    expect(allowed, isEmpty);

    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    final toggle = settingsSwitch('Allow screen capture');
    expect(tester.widget<Switch>(toggle).value, isFalse);

    await tester.tap(toggle);
    await settle(tester);
    expect(tester.widget<Switch>(toggle).value, isTrue);
    expect(allowed, [true]);
    await tester.runAsync(() async {
      expect((await ScreenCapture.load()).allowed, isTrue);
    });
    expect(allowed, [true, true]);
    await close(tester);
  });

  testWidgets(
    'clears a copied password after the delay of the settings on Linux',
    (tester) async {
      setScreen(tester, const Size(1280, 800));
      String? copied;
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        switch (call.method) {
          case 'Clipboard.setData':
            copied = (call.arguments as Map)['text'] as String;
          case 'Clipboard.getData':
            return {'text': copied};
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await open(tester, items: [github]);
      await tester.pumpWidget(
        SubmarineApp(
          vaults: vaults,
          lock: lock,
          appearance: appearance,
          clipboard: clipboard,
          screenCapture: screenCapture,
        ),
      );
      await settle(tester);
      Finder copyOf(String label) => find.descendant(
        of: find.ancestor(
          of: find.text(label),
          matching: find.byType(FieldTile),
        ),
        matching: find.byTooltip('Copy'),
      );

      await tester.tap(find.byTooltip('Settings'));
      await settle(tester);
      await tester.tap(find.text('30 seconds'));
      await settle(tester);
      await tester.tap(find.text('10 seconds'));
      await settle(tester);
      await tester.runAsync(() async {
        expect(
          (await AppClipboard.load()).timeout,
          ClipboardTimeout.tenSeconds,
        );
      });

      await tester.tap(find.byTooltip('Personal'));
      await settle(tester);
      await tester.tap(find.text('GitHub'));
      await settle(tester);
      await tester.tap(copyOf('Password'));
      await tester.pump(const Duration(seconds: 9));
      expect(copied, 'Tr0ub4dor&3');
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(copied, '');

      await tester.tap(copyOf('Password'));
      await tester.pump();
      await tester.tap(copyOf('Username'));
      await tester.pump(const Duration(seconds: 10));
      await tester.pump();
      expect(copied, 'alice-dev');
      await close(tester);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets('goes from tab to tab on a phone, each where it was left', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844));
    await open(tester, items: [github], withFamily: true);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);

    await tester.tap(find.byTooltip('Vaults'));
    await settle(tester);
    await tester.tap(find.text('Family'));
    await settle(tester);
    expect(find.text('Family'), findsOneWidget);

    await tester.tap(find.text('Generator'));
    await settle(tester);
    expect(find.text('Passphrase'), findsOneWidget);
    expect(find.text('Family'), findsNothing);

    await tester.tap(find.text('Settings'));
    await settle(tester);
    expect(find.text('Security'), findsOneWidget);

    await tester.tap(find.text('Vault'));
    await settle(tester);
    expect(find.text('Family'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await settle(tester);
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.text('Security'), findsNothing);
    expect(find.text('Family'), findsOneWidget);
    await close(tester);
  });

  testWidgets('opens the generator from the rail on a desktop', (tester) async {
    setScreen(tester, const Size(1280, 800));
    await open(tester, items: [github]);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);

    await tester.tap(find.byTooltip('Generator'));
    await settle(tester);
    expect(find.text('Passphrase'), findsOneWidget);
    expect(find.text('GitHub'), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byTooltip('Personal'));
    await settle(tester);
    expect(find.text('GitHub'), findsOneWidget);
    await close(tester);
  });

  testWidgets('shares the options of the generator tab with its sheet', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844));
    await open(tester, items: [github]);
    await tester.pumpWidget(
      SubmarineApp(
        vaults: vaults,
        lock: lock,
        appearance: appearance,
        clipboard: clipboard,
        screenCapture: screenCapture,
      ),
    );
    await settle(tester);

    await tester.tap(find.text('Generator'));
    await settle(tester);
    expect(find.text('Number of words'), findsNothing);
    await tester.tap(find.text('Passphrase'));
    await settle(tester);
    expect(find.text('Number of words'), findsOneWidget);
    expect((await GeneratorSettings.read()).type, GeneratorType.passphrase);

    await tester.tap(find.text('Vault'));
    await settle(tester);
    await tester.tap(find.byTooltip('New item'));
    await settle(tester);
    await tester.tap(find.byTooltip('Generate a password'));
    await settle(tester);
    expect(find.text('Use this passphrase'), findsOneWidget);
    await tester.tap(find.text('Password').last);
    await settle(tester);
    // Closes the sheet from its barrier, then the untouched form.
    await tester.tapAt(const Offset(195, 20));
    await settle(tester);
    await tester.binding.handlePopRoute();
    await settle(tester);

    await tester.tap(find.text('Generator'));
    await settle(tester);
    expect(find.text('Number of words'), findsNothing);
    expect(find.text('Length'), findsOneWidget);
    await close(tester);
  });

  testWidgets('says why the vaults could not be read, and tries again', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844));
    var retries = 0;
    await tester.pumpWidget(
      StorageErrorApp(
        error: PlatformException(
          code: 'Exception encountered',
          message: 'Key mismatch after algorithm change',
        ),
        onRetry: () async {
          retries++;
        },
      ),
    );
    await settle(tester);
    expect(find.text('Your vaults could not be read.'), findsOneWidget);
    expect(find.text('Key mismatch after algorithm change'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await settle(tester);
    expect(retries, 1);
  });
}

/// Lets the user in every time, and counts how often it was asked to.
class FakeFilePicker extends FilePickerPlatform {
  PlatformFile? picked;
  String? savedName;
  Uint8List? savedBytes;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => picked;

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    savedName = fileName;
    savedBytes = bytes;
    return Uri.file('/tmp/$fileName');
  }
}

final class FakeFile extends PlatformFile {
  FakeFile(this.name, String content) : _bytes = utf8.encode(content);

  @override
  final String name;
  final Uint8List _bytes;

  @override
  Uri get uri => Uri.file('/tmp/$name');

  @override
  Never get xFile => throw UnimplementedError();

  @override
  int? lengthSync() => _bytes.length;

  @override
  Future<int?> length() async => _bytes.length;

  @override
  Future<Uint8List> readAsBytes() async => _bytes;

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(_bytes);
}

class FakeDeviceAuth implements DeviceAuth {
  var available = true;
  var asked = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async {
    asked++;
    return true;
  }
}
