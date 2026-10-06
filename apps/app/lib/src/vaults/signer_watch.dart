import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ndk/ndk.dart' show PendingSignerRequest;

const defaultSignerPatience = Duration(seconds: 2);

/// What a signer seems to wait on the user for: its requests, once it
/// answered none for [patience]. A signer that approves by itself, such as a
/// bunker set to accept everything, keeps answering within it.
class SignerWatch extends ChangeNotifier {
  SignerWatch(
    Stream<List<PendingSignerRequest>> requests, {
    required this.patience,
  }) {
    _subscription = requests.listen(_update);
  }

  final Duration patience;
  late final StreamSubscription<List<PendingSignerRequest>> _subscription;
  var _pending = const <PendingSignerRequest>[];
  var _silent = false;
  Timer? _silence;

  List<PendingSignerRequest> get waiting => _silent ? _pending : const [];

  /// Whether the signer has no request left.
  bool get idle => _pending.isEmpty;

  /// Leaves out [ids], which the user cancelled rather than the signer
  /// answered.
  void cancelled(Iterable<String> ids) {
    final cancelled = ids.toSet();
    _set([
      for (final request in _pending)
        if (!cancelled.contains(request.id)) request,
    ], heard: false);
  }

  void _update(List<PendingSignerRequest> requests) {
    final ids = {for (final request in requests) request.id};
    final answered = _pending.any((request) => !ids.contains(request.id));
    _set(requests, heard: _pending.isEmpty || answered);
  }

  void _set(List<PendingSignerRequest> requests, {required bool heard}) {
    final before = waiting;
    final wasIdle = idle;
    _pending = requests;
    if (requests.isEmpty) {
      _silence?.cancel();
      _silent = false;
    } else if (heard) {
      _silence?.cancel();
      _silent = false;
      _silence = Timer(patience, () {
        _silent = true;
        notifyListeners();
      });
    }
    if (!listEquals(before, waiting) || idle != wasIdle) notifyListeners();
  }

  @override
  void dispose() {
    _silence?.cancel();
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
