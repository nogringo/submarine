import 'package:ndk/ndk.dart';

/// A new mailbox at [bridge]: the nsec of a key made for it alone, for a
/// hidden field of the item, and its address, that key's npub at [bridge].
/// The key comes from [signerFactory], the one the app gives ndk.
({String key, String address}) generateMailbox(
  String bridge, {
  required LocalEventSignerFactory signerFactory,
}) {
  final (privateKey, publicKey) = signerFactory.generateKeyPair();
  return (
    key: Nip19.encodePrivateKey(privateKey),
    address: '${Nip19.encodePubKey(publicKey)}@$bridge',
  );
}
