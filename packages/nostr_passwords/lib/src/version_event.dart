import 'dart:convert';

import 'package:ndk/ndk.dart';

import 'envelope.dart';

const versionEventKind = 21270;

/// [signerFactory] makes the one-time key of the gift wrap: on web, ndk_flutter
/// has a faster one than the pure Dart default.
Future<Nip01Event> wrapEnvelope(
  Envelope envelope,
  EventSigner vault, {
  LocalEventSignerFactory signerFactory = const Bip340EventSignerFactory(),
}) async {
  final version = await vault.sign(
    Nip01Event(
      pubKey: vault.getPublicKey(),
      kind: versionEventKind,
      tags: [
        ['-'],
      ],
      content: jsonEncode(envelope.toJson()),
      createdAt: envelope.modifiedAt.millisecondsSinceEpoch ~/ 1000,
    ),
  );
  return GiftWrap.wrapEvent(
    recipientPublicKey: vault.getPublicKey(),
    sealEvent: version,
    eventSignerFactory: signerFactory,
    randomizeCreatedAtBefore: version.createdAt,
  );
}

Future<Envelope> unwrapEnvelope(
  Nip01Event wrap,
  EventSigner vault, {
  EventVerifier? verifier,
}) async {
  if (wrap.kind != GiftWrap.kGiftWrapEventkind) {
    throw FormatException('Not a gift wrap: kind ${wrap.kind}');
  }
  final plaintext = await vault.decryptNip44(
    ciphertext: wrap.content,
    senderPubKey: wrap.pubKey,
  );
  if (plaintext == null) {
    throw FormatException('Cannot decrypt gift wrap ${wrap.id}');
  }
  final version = Nip01EventModel.fromJson(jsonDecode(plaintext));

  // Anyone can wrap an event to the vault, only its own signature proves the item is ours.
  if (version.kind != versionEventKind ||
      version.pubKey != vault.getPublicKey() ||
      !await (verifier ?? Bip340EventVerifier()).verify(version)) {
    throw FormatException('Gift wrap ${wrap.id} holds no valid version event');
  }
  return Envelope.fromJson(jsonDecode(version.content));
}
