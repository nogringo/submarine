import 'package:isar/isar.dart';
import 'package:nostr/nostr.dart';
import 'package:submarine/models/nostr_event.dart';
import 'package:submarine/models/nostr_relay.dart';
import 'package:submarine/repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NostrRelayManager {
  int nostrRelayId;
  NostrRelay? nostrRelay;

  late WebSocketChannel webSocket;

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
      webSocket = WebSocketChannel.connect(Uri.parse(nostrRelay!.url));
    } catch (e) {
      return;
    }

    webSocket.stream.listen(onMessage);

    webSocket.sink.add(requestWithFilter.serialize());
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
        // !
        try {
          await isar.writeTxn(() async {
            await isar.nostrEvents.put(nostrEvent!);
          });
        } catch (e) {
          //
        }
      }

      nostrEvent.nostrRelays.add(nostrRelay!);
      // !
      try {
        await isar.writeTxn(() async {
          await nostrEvent!.nostrRelays.save();
        });
      } catch (e) {
        //
      }

      return;
    }

    print('Received event: ${message.type}');
  }

  sendItem(String item) {
    try {
      webSocket.sink.add(item);
    } catch (e) {
      //
    }
  }

  disconnect() async {
    try {
      await webSocket.sink.close();
    } catch (e) {
      //
    }
  }
}
