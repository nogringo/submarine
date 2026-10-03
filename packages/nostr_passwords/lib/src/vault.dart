import 'dart:math';

import 'package:ndk/ndk.dart';

import 'cipher/cipher.dart';
import 'envelope.dart';
import 'version_event.dart';

class Vault {
  Vault({required this.ndk, required this.signer, this.relays});

  final Ndk ndk;
  final EventSigner signer;

  /// Relays the vault publishes to. When null, ndk picks them (outbox model).
  final List<String>? relays;

  Future<Envelope> createItem(Cipher cipher) async {
    final envelope = Envelope(
      id: _randomId(),
      type: 'item',
      rev: _randomId(),
      parents: const [],
      modifiedAt: DateTime.now().toUtc(),
      data: cipher.toJson(),
    );
    await _publish(envelope);
    return envelope;
  }

  Future<void> _publish(Envelope envelope) async {
    final wrap = await wrapEnvelope(envelope, signer);
    final responses = await ndk.broadcast
        .broadcast(nostrEvent: wrap, specificRelays: relays)
        .broadcastDoneFuture;
    if (!responses.any((response) => response.broadcastSuccessful)) {
      throw PublishException(envelope, {
        for (final response in responses) response.relayUrl: response.msg,
      });
    }
  }
}

class PublishException implements Exception {
  PublishException(this.envelope, this.relayMessages);

  final Envelope envelope;
  final Map<String, String> relayMessages;

  @override
  String toString() =>
      'PublishException: no relay accepted rev ${envelope.rev} of ${envelope.id}';
}

final _random = Random.secure();

String _randomId() => [
  for (var i = 0; i < 16; i++)
    _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
].join();
