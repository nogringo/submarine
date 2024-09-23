import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

Future<String> nostrSendEvent(String event, String url) async {
  final wsUrl = Uri.parse(url);
  final channel = WebSocketChannel.connect(wsUrl);
  final completer = Completer<String>();

  await channel.ready;

  channel.stream.listen((eventPayload) {
    completer.complete(eventPayload);
    channel.sink.close();
  });

  channel.sink.add(event);

  return completer.future;
}

Future<List<String>> nostrFetchEvents(String request, String url) async {
  final wsUrl = Uri.parse(url);
  final channel = WebSocketChannel.connect(wsUrl);
  final completer = Completer<List<String>>();

  await channel.ready;

  List<String> results = [];
  channel.stream.listen((eventPayload) {
    final jsonObj = jsonDecode(eventPayload);
    String type = jsonObj[0];
    if (type == 'EVENT') {
      results.add(jsonEncode(jsonObj[2]));
    } else if (type == 'EOSE') {
      completer.complete(results);
      channel.sink.close();
    }
  });

  channel.sink.add(request);

  return completer.future;
}
