// Renders the screenshots of the READMEs into screenshots/:
// flutter test tool/screenshots_test.dart
import 'dart:convert';
import 'dart:io'
    show File, HttpOverrides, HttpServer, InternetAddress, WebSocketTransformer;
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show RenderRepaintBoundary, debugDisableShadows;
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:flutter_test/flutter_test.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast_memory.dart' show newDatabaseFactoryMemory;
import 'package:submarine/src/app.dart';
import 'package:submarine/src/clipboard.dart';
import 'package:submarine/src/lock/app_lock.dart';
import 'package:submarine/src/mail/mail_settings.dart';
import 'package:submarine/src/screen_capture.dart';
import 'package:submarine/src/theme/appearance.dart';
import 'package:submarine/src/vaults/vault_storage.dart';
import 'package:submarine/src/vaults/vaults.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

const desktop = Size(1280, 800);
const phone = Size(390, 844);

Cipher login(
  String name,
  String uri,
  String username, {
  String? totp,
  bool favorite = false,
}) => Cipher(
  type: CipherType.login,
  name: name,
  favorite: favorite,
  login: Login(
    uris: [LoginUri(uri)],
    username: username,
    password: 'correct horse battery staple',
    totp: totp,
  ),
);

final personal = [
  login(
    'GitHub',
    'https://github.com',
    'alice-dev',
    totp: 'JBSWY3DPEHPK3PXP',
    favorite: true,
  ),
  login('Proton Mail', 'https://proton.me', 'alice@proton.me', favorite: true),
  login('Amazon', 'https://www.amazon.com', 'alice@proton.me'),
  login('Duolingo', 'https://www.duolingo.com', 'alice.martin'),
  login('Mastodon', 'https://mastodon.social', '@alice'),
  login('Strava', 'https://www.strava.com', 'alice@proton.me'),
  Cipher(
    type: CipherType.card,
    name: 'Visa',
    card: PaymentCard(
      cardholderName: 'Alice Martin',
      brand: 'Visa',
      number: '4242424242424242',
      expMonth: '04',
      expYear: '2030',
      code: '123',
    ),
  ),
  Cipher(
    type: CipherType.secureNote,
    name: 'Passport number',
    notes: '19FR04521',
    secureNote: SecureNote(),
  ),
];

final family = [
  login('Netflix', 'https://www.netflix.com', 'family@proton.me'),
  login('Spotify', 'https://www.spotify.com', 'family@proton.me'),
  Cipher(
    type: CipherType.secureNote,
    name: 'Home Wi-Fi',
    notes: 'Network: Martin\nPassword: plum-ocean-violin-42',
    secureNote: SecureNote(),
  ),
];

final work = [
  login('Slack', 'https://slack.com', 'alice@example.com'),
  login('Figma', 'https://www.figma.com', 'alice@example.com'),
  login('AWS', 'https://aws.amazon.com', 'alice', totp: 'JBSWY3DPEHPK3PXP'),
];

void main() {
  late Ndk ndk;
  late Vaults vaults;
  late AppLock lock;
  late Appearance appearance;
  late AppClipboard clipboard;
  late ScreenCapture screenCapture;
  late MailSettings mail;
  final boundary = GlobalKey();
  final relay = _Relay();

  setUpAll(() async {
    final manifest =
        jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
    for (final family in manifest.cast<Map<String, dynamic>>()) {
      final loader = FontLoader(family['family'] as String);
      for (final font in (family['fonts'] as List).cast<Map>()) {
        loader.addFont(rootBundle.load(font['asset'] as String));
      }
      await loader.load();
    }
    // flutter_test answers every HTTP request, websockets included, with 400.
    HttpOverrides.global = null;
    await relay.start();
  });

  tearDownAll(() => relay.stop());

  /// The app on a [size] screen in [theme], with the Personal, Family and Work
  /// vaults unless [empty].
  Future<void> start(
    WidgetTester tester,
    Size size,
    ThemeMode theme, {
    bool empty = false,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // flutter_test draws shadows as solid black outlines.
    debugDisableShadows = false;
    await tester.runAsync(() async {
      ndk = Ndk(
        NdkConfig(
          cache: MemCacheManager(),
          eventVerifier: Bip340EventVerifier(),
          bootstrapRelays: [],
          logLevel: LogLevel.off,
          pendingDeliveryRetriesEnabled: false,
        ),
      );
      final records = <VaultRecord>[];
      if (!empty) {
        for (final (name, color, items) in [
          ('Personal', VaultColor.blue, personal),
          ('Family', VaultColor.orange, family),
          ('Work', VaultColor.green, work),
        ]) {
          const factory = Bip340EventSignerFactory();
          final (privateKey, _) = factory.generateKeyPair();
          final vault = Vault(
            ndk: ndk,
            signer: factory.create(privateKey: privateKey),
            relays: const [],
          );
          for (final item in items) {
            await vault.createItem(item);
          }
          records.add(
            VaultRecord(
              login: KeyLogin(privateKey),
              name: name,
              color: color.color,
            ),
          );
        }
      }
      final deviceKey = SymmetricCryptoKey.generate();
      // ignore: invalid_use_of_visible_for_testing_member
      FlutterSecureStorage.setMockInitialValues({
        'vaultsKey': base64.encode(deviceKey.bytes),
        if (records.isNotEmpty)
          'vaults': await deviceKey.encryptString(
            jsonEncode([for (final r in records) r.toJson()]),
          ),
      });
      final database = await newDatabaseFactoryMemory().openDatabase('sync');
      vaults = await Vaults.load(
        ndk: ndk,
        engine: SyncEngine(ndk, store: SembastSyncStore(database)),
        storage: VaultStorage(),
        database: database,
        relays: [relay.url],
        indexers: const [],
        signerPatience: Duration.zero,
      );
      lock = await AppLock.load(vaults: vaults);
      while (vaults.all.any((vault) => !vault.loaded)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      appearance = await Appearance.load();
      await appearance.setThemeMode(theme);
      clipboard = await AppClipboard.load();
      screenCapture = await ScreenCapture.load();
      mail = await MailSettings.load();
    });
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: SubmarineApp(
          vaults: vaults,
          lock: lock,
          appearance: appearance,
          clipboard: clipboard,
          screenCapture: screenCapture,
          mail: mail,
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    lock.dispose();
    appearance.dispose();
    clipboard.dispose();
    screenCapture.dispose();
    mail.dispose();
    await tester.runAsync(() async {
      await vaults.pauseSync();
      vaults.dispose();
      await ndk.destroy();
    });
    debugDisableShadows = true;
  }

  Future<void> capture(WidgetTester tester, String name) async {
    await settle(tester);
    final render = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(boundary),
    );
    await tester.runAsync(() async {
      final image = await render.toImage(pixelRatio: 2);
      final png = await image.toByteData(format: ImageByteFormat.png);
      final file = File('screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(png!.buffer.asUint8List());
    });
  }

  /// Opens GitHub at the start of a TOTP period, for its ring to read full.
  Future<void> openGitHub(WidgetTester tester) async {
    await tester.runAsync(() async {
      final left = 30 - DateTime.now().second % 30;
      if (left < 25) await Future<void>.delayed(Duration(seconds: left));
    });
    await tester.tap(find.text('GitHub'));
  }

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    final suffix = theme.name;

    testWidgets('desktop, $suffix', (tester) async {
      await start(tester, desktop, theme);
      await openGitHub(tester);
      await capture(tester, 'desktop-$suffix');
      await close(tester);
    });

    testWidgets('phone welcome, $suffix', (tester) async {
      await start(tester, phone, theme, empty: true);
      await capture(tester, 'phone-welcome-$suffix');
      await close(tester);
    });

    testWidgets('phone list, $suffix', (tester) async {
      await start(tester, phone, theme);
      await capture(tester, 'phone-list-$suffix');
      await close(tester);
    });

    testWidgets('phone generator, $suffix', (tester) async {
      await start(tester, phone, theme);
      await tester.tap(find.text('Generator'));
      await capture(tester, 'phone-generator-$suffix');
      await close(tester);
    });
  }
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Accepts every event and holds none, for the vaults to sync.
class _Relay {
  late final HttpServer _server;

  String get url => 'ws://127.0.0.1:${_server.port}';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.transform(WebSocketTransformer()).listen((socket) {
      socket.listen((data) {
        switch (jsonDecode(data as String)) {
          case ['REQ', final String id, ...]:
            socket.add(jsonEncode(['EOSE', id]));
          case ['EVENT', final Map<String, dynamic> event]:
            socket.add(jsonEncode(['OK', event['id'], true, '']));
        }
      });
    });
  }

  Future<void> stop() => _server.close(force: true);
}
