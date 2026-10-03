import 'dart:convert';

import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

void main() {
  const signerFactory = Bip340EventSignerFactory();
  late EventSigner vault;
  late Envelope envelope;

  setUp(() {
    vault = signerFactory.createWithNewKeyPair();
    envelope = Envelope(
      id: 'item-1',
      type: 'item',
      rev: 'rev-1',
      parents: const [],
      modifiedAt: DateTime.utc(2026, 9, 30, 10),
      data: {
        'type': 1,
        'name': 'Boulanger',
        'login': {'username': 'alice@example.com', 'password': 'hunter2'},
      },
    );
  });

  test('the gift wrap hides the vault and the timestamp', () async {
    final wrap = await wrapEnvelope(envelope, vault);
    final versionCreatedAt = envelope.modifiedAt.millisecondsSinceEpoch ~/ 1000;

    expect(wrap.kind, 1059);
    expect(wrap.pubKey, isNot(vault.getPublicKey()));
    expect(wrap.tags, [
      ['p', vault.getPublicKey()],
    ]);
    expect(wrap.createdAt, lessThan(versionCreatedAt));
    expect(wrap.createdAt, greaterThanOrEqualTo(versionCreatedAt - 2 * 86400));
    expect(wrap.content, isNot(contains('hunter2')));
  });

  test('the vault unwraps its own item', () async {
    final wrap = await wrapEnvelope(envelope, vault);

    final unwrapped = await unwrapEnvelope(wrap, vault);

    expect(unwrapped.toJson(), envelope.toJson());
  });

  test('a version event signed by another key is rejected', () async {
    final attacker = signerFactory.createWithNewKeyPair();
    final forged = await attacker.sign(
      Nip01Event(
        pubKey: attacker.getPublicKey(),
        kind: versionEventKind,
        tags: [
          ['-'],
        ],
        content: jsonEncode(envelope.toJson()),
      ),
    );
    final wrap = await GiftWrap.wrapEvent(
      recipientPublicKey: vault.getPublicKey(),
      sealEvent: forged,
      eventSignerFactory: signerFactory,
    );

    expect(unwrapEnvelope(wrap, vault), throwsFormatException);
  });
}
