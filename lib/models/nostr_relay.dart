import 'package:isar/isar.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/repository.dart';

part 'nostr_relay.g.dart';

@collection
class NostrRelay {
  Id id = Isar.autoIncrement;

  String encryptedUrl;

  @ignore
  String get url => decryptText(encryptedUrl, Repository.to.secretKey!);

  NostrRelay(this.encryptedUrl);
}
