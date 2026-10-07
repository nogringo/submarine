import 'package:nostr_passwords/nostr_passwords.dart';

class MemoryVersionStore implements VersionStore {
  final entries = <String, String>{};

  @override
  Future<Map<String, String>> read() async => {...entries};

  @override
  Future<void> write(Map<String, String> entries) async =>
      this.entries.addAll(entries);

  @override
  Future<void> remove(Iterable<String> wrapIds) async =>
      wrapIds.forEach(entries.remove);
}
