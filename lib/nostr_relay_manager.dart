import 'dart:io';

import 'package:isar/isar.dart';
import 'package:nostr/nostr.dart';
import 'package:submarine/models/nostr_event.dart';
import 'package:submarine/models/nostr_relay.dart';
import 'package:submarine/repository.dart';

class NostrRelayManager {
  int nostrRelayId;
  NostrRelay? nostrRelay;

  late WebSocket webSocket;

  NostrRelayManager(this.nostrRelayId) {
    initClass();
  }

  initClass() async {
    nostrRelay = await Isar.getInstance()!.nostrRelays.get(nostrRelayId);

    if (nostrRelay == null) return;

    Request requestWithFilter = Request(generate64RandomHexChars(), [
      Filter(kinds: [1], authors: [Repository.to.nostrKey!.public])
    ]);

    try {
      webSocket = await WebSocket.connect(nostrRelay!.url);
    } catch (e) {
      return;
    }

    webSocket.listen(onMessage);

    webSocket.add(requestWithFilter.serialize());
  }

  onMessage(eventPayload) async {
    Message message = Message.deserialize(eventPayload);

    if (message.type == "EVENT") {
      final event = Event(
        message.message.id,
        message.message.pubkey,
        message.message.createdAt,
        message.message.kind,
        message.message.tags,
        message.message.content,
        message.message.sig,
      );

      final isar = Isar.getInstance()!;

      NostrEvent? nostrEvent = await isar.nostrEvents
          .filter()
          .idEqualTo(message.message.id)
          .findFirst();

      final nostrEventNotFound = nostrEvent == null;
      if (nostrEventNotFound) {
        nostrEvent = NostrEvent(event.serialize());
        await isar.writeTxn(() async {
          await isar.nostrEvents.put(nostrEvent!);
        });
      }

      nostrEvent.nostrRelays.add(nostrRelay!);
      await isar.writeTxn(() async {
        await nostrEvent!.nostrRelays.save();
      });

      return;
    }

    print('Received event: ${message.type}');
  }

  sendItem(String item) {
    webSocket.add(item);
  }

  disconnect() async {
    await webSocket.close();
  }
}
