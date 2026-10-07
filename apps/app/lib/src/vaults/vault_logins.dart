import 'package:flutter/foundation.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_flutter/ndk_flutter.dart'
    show Nip07EventSigner, Nip55Signer;
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import 'vault_storage.dart';

/// Where a signer and the app talk after a Nostr Connect code (NIP-46).
const nostrConnectRelays = [
  'wss://relay.nmail.li',
  'wss://relay.ditto.pub',
  'wss://relay.primal.net',
];

const bunkerClient = Nip46ClientMetadata(
  name: 'Submarine',
  url: 'https://nogringo.github.io/submarine/',
  image: 'https://nogringo.github.io/submarine/icons/Icon-192.png',
  perms: vaultSignerPermissions,
);

bool get canUseExtension => kIsWeb;

bool get canUseSignerApp =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

bool isBunkerUrl(String text) => text.trim().startsWith('bunker://');

String signerName(AppLocalizations l10n, SignerLogin login) => switch (login) {
  ExtensionLogin() => l10n.browserExtension,
  BunkerLogin() => l10n.bunker,
  SignerAppLogin() => l10n.signerApp,
};

/// No signer of the kind asked for is on this device.
class NoSignerException implements Exception {
  const NoSignerException();
}

/// Null when the user refuses.
Future<ExtensionLogin?> loginWithExtension() async {
  final signer = Nip07EventSigner();
  if (!signer.canSign()) throw const NoSignerException();
  try {
    return ExtensionLogin(await signer.getPublicKeyAsync());
  } on SignerRequestRejectedException {
    return null;
  }
}

/// Null when the user refuses.
Future<SignerAppLogin?> loginWithSignerApp() async {
  const signer = Nip55Signer();
  if (!await signer.isAppInstalled()) throw const NoSignerException();
  final result = await signer.login();
  return result == null
      ? null
      : SignerAppLogin(result.pubkey, package: result.package);
}

/// Null when the bunker never answers. [onAuthUrl] gets the page where the
/// bunker asks to approve the app. Throws an [ArgumentError] when [url] lacks
/// a relay or a secret.
Future<BunkerLogin?> loginWithBunker(
  Ndk ndk,
  String url, {
  required void Function(String url) onAuthUrl,
}) async {
  final connection = await ndk.bunkers.connectWithBunkerUrl(
    url.trim(),
    authCallback: onAuthUrl,
    clientMetadata: bunkerClient,
  );
  return connection == null ? null : _bunkerLogin(ndk, connection, onAuthUrl);
}

/// Waits for a signer to scan or paste [connect]'s code. Null when none does.
Future<BunkerLogin?> loginWithNostrConnect(
  Ndk ndk,
  NostrConnect connect, {
  required void Function(String url) onAuthUrl,
}) async {
  final connection = await ndk.bunkers.connectWithNostrConnect(
    connect,
    authCallback: onAuthUrl,
  );
  return connection == null ? null : _bunkerLogin(ndk, connection, onAuthUrl);
}

Future<BunkerLogin> _bunkerLogin(
  Ndk ndk,
  BunkerConnection connection,
  void Function(String url) onAuthUrl,
) async {
  final signer = ndk.bunkers.createSigner(connection, authCallback: onAuthUrl);
  try {
    return BunkerLogin(await signer.getPublicKeyAsync(), connection);
  } finally {
    await signer.dispose();
  }
}
