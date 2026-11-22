// The app with made-up vaults, rendered by the screenshot and video tests of
// this folder.
import 'dart:convert';
import 'dart:io'
    show File, HttpOverrides, HttpServer, InternetAddress, WebSocketTransformer;
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/rendering.dart'
    show RenderRepaintBoundary, debugDisableShadows;
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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

class DemoApp {
  late Ndk _ndk;
  late Vaults _vaults;
  late AppLock _lock;
  late Appearance _appearance;
  late AppClipboard _clipboard;
  late ScreenCapture _screenCapture;
  late MailSettings _mail;
  final _boundary = GlobalKey();
  final _relay = _Relay();

  Future<void> setUp() async {
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
    await _relay.start();
  }

  Future<void> tearDown() => _relay.stop();

  /// The app on a [size] screen in [theme], with the Personal, Family and Work
  /// vaults unless [empty], inside [wrap] if given.
  Future<void> start(
    WidgetTester tester,
    Size size,
    ThemeMode theme, {
    bool empty = false,
    Widget Function(Widget app)? wrap,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // flutter_test draws shadows as solid black outlines.
    debugDisableShadows = false;
    await tester.runAsync(() async {
      _ndk = Ndk(
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
            ndk: _ndk,
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
      _vaults = await Vaults.load(
        ndk: _ndk,
        engine: SyncEngine(_ndk, store: SembastSyncStore(database)),
        storage: VaultStorage(),
        database: database,
        relays: [_relay.url],
        indexers: const [],
        signerPatience: Duration.zero,
      );
      _lock = await AppLock.load(vaults: _vaults);
      while (_vaults.all.any((vault) => !vault.loaded)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      _appearance = await Appearance.load();
      await _appearance.setThemeMode(theme);
      _clipboard = await AppClipboard.load();
      _screenCapture = await ScreenCapture.load();
      _mail = await MailSettings.load();
    });
    final app = SubmarineApp(
      vaults: _vaults,
      lock: _lock,
      appearance: _appearance,
      clipboard: _clipboard,
      screenCapture: _screenCapture,
      mail: _mail,
    );
    await tester.pumpWidget(
      RepaintBoundary(key: _boundary, child: wrap?.call(app) ?? app),
    );
    await settle(tester);
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    _lock.dispose();
    _appearance.dispose();
    _clipboard.dispose();
    _screenCapture.dispose();
    _mail.dispose();
    await tester.runAsync(() async {
      await _vaults.pauseSync();
      _vaults.dispose();
      await _ndk.destroy();
    });
    debugDisableShadows = true;
  }

  /// Writes the screen as it stands into [file], a PNG.
  Future<void> capture(
    WidgetTester tester,
    File file, {
    double pixelRatio = 2,
  }) async {
    final render = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_boundary),
    );
    await tester.runAsync(() async {
      final image = await render.toImage(pixelRatio: pixelRatio);
      final png = await image.toByteData(format: ImageByteFormat.png);
      image.dispose();
      await file.parent.create(recursive: true);
      await file.writeAsBytes(png!.buffer.asUint8List());
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
