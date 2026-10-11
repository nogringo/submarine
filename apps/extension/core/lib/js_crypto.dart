import 'dart:js_interop';

import 'package:ndk/ndk.dart';

/// Pure-Dart secp256k1 compiled to JavaScript is about a hundred times slower
/// than noble, which the background sets as `nostrCrypto`.
@JS('nostrCrypto')
external _NostrCrypto get _js;

extension type _NostrCrypto._(JSObject _) implements JSObject {
  external String sign(String id, String privateKey);
  external bool verify(String id, String publicKey, String sig);
  external String publicKey(String privateKey);
  external String generatePrivateKey();
  external String nip44Encrypt(
    String plaintext,
    String privateKey,
    String publicKey,
  );
  external String nip44Decrypt(
    String payload,
    String privateKey,
    String publicKey,
  );
}

class JsEventSigner extends Bip340EventSigner {
  JsEventSigner({required super.privateKey, required super.publicKey});

  @override
  Future<Nip01Event> sign(Nip01Event event) async =>
      event.copyWith(sig: _js.sign(event.id, privateKey!));

  @override
  Future<String?> encryptNip44({
    required String plaintext,
    required String recipientPubKey,
  }) async => _js.nip44Encrypt(plaintext, privateKey!, recipientPubKey);

  @override
  Future<String?> decryptNip44({
    required String ciphertext,
    required String senderPubKey,
  }) async => _js.nip44Decrypt(ciphertext, privateKey!, senderPubKey);
}

class JsEventSignerFactory extends Bip340EventSignerFactory {
  const JsEventSignerFactory();

  @override
  EventSigner create({String? privateKey, String? publicKey}) => JsEventSigner(
    privateKey: privateKey,
    publicKey: publicKey ?? derivePublicKey(privateKey!),
  );

  @override
  String derivePublicKey(String privateKey) => _js.publicKey(privateKey);

  @override
  (String, String) generateKeyPair() {
    final privateKey = _js.generatePrivateKey();
    return (privateKey, derivePublicKey(privateKey));
  }
}

class JsEventVerifier implements EventVerifier {
  const JsEventVerifier();

  @override
  Future<bool> verify(Nip01Event event) async =>
      event.sig != null &&
      Nip01Utils.isIdValid(event) &&
      _js.verify(event.id, event.pubKey, event.sig!);
}
