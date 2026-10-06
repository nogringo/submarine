import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ndk/ndk.dart' show PendingSignerRequest, SignerMethod;
import 'package:submarine/src/vaults/signer_watch.dart';

void main() {
  late StreamController<List<PendingSignerRequest>> requests;
  late SignerWatch watch;

  PendingSignerRequest request(String id) => PendingSignerRequest(
    id: id,
    method: SignerMethod.nip44Decrypt,
    createdAt: DateTime(2026),
    signerPubkey: 'vault',
  );
  final a = request('a');
  final b = request('b');
  final c = request('c');

  Future<void> signerHas(
    WidgetTester tester,
    List<PendingSignerRequest> pending,
  ) async {
    requests.add(pending);
    await tester.pump();
  }

  /// Made in the test, for its timer to follow the test's clock.
  void startWatch() {
    requests = StreamController();
    watch = SignerWatch(requests.stream, patience: const Duration(seconds: 2));
    addTearDown(watch.dispose);
  }

  testWidgets('shows nothing while the signer keeps answering', (tester) async {
    startWatch();
    await signerHas(tester, [a, b, c]);
    await tester.pump(const Duration(milliseconds: 1500));
    await signerHas(tester, [b, c]);
    await tester.pump(const Duration(milliseconds: 1500));
    await signerHas(tester, [c]);
    await tester.pump(const Duration(milliseconds: 1500));

    expect(watch.waiting, isEmpty);

    await tester.pump(const Duration(milliseconds: 500));

    expect(watch.waiting, [c]);
  });

  testWidgets('shows a silent signer at once its new requests', (tester) async {
    startWatch();
    await signerHas(tester, [a]);
    await tester.pump(const Duration(seconds: 2));
    expect(watch.waiting, [a]);

    await signerHas(tester, [a, b]);

    expect(watch.waiting, [a, b]);
  });

  testWidgets('takes no cancelled request for an answer', (tester) async {
    startWatch();
    await signerHas(tester, [a, b]);
    await tester.pump(const Duration(seconds: 2));

    watch.cancelled(['a']);
    expect(watch.waiting, [b]);
    await signerHas(tester, [b]);

    expect(watch.waiting, [b]);
  });

  testWidgets('forgets the requests once the signer has none', (tester) async {
    startWatch();
    await signerHas(tester, [a]);
    await tester.pump(const Duration(seconds: 2));

    await signerHas(tester, []);

    expect(watch.waiting, isEmpty);
    expect(watch.idle, isTrue);
  });
}
