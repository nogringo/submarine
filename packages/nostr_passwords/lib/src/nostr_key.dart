import 'package:ndk/ndk.dart';

/// A new Nostr key, for a site that asks for an nsec: like an email address,
/// each site gets one of its own. The key comes from [signerFactory], the one
/// the app gives ndk.
({String nsec, String npub}) generateNostrKey({
  required LocalEventSignerFactory signerFactory,
}) {
  final (privateKey, publicKey) = signerFactory.generateKeyPair();
  return (
    nsec: Nip19.encodePrivateKey(privateKey),
    npub: Nip19.encodePubKey(publicKey),
  );
}
