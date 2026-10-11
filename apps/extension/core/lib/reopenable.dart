/// What opens on demand and closes at will, an opening waiting for the
/// closing before it: sembast hands out a database being closed again, which
/// the closing then closes under the new opener.
class Reopenable<T> {
  Reopenable(this._open, this._close);

  final Future<T> Function() _open;
  final Future<void> Function(T value) _close;

  Future<T>? _opening;
  Future<void> _closing = Future.value();

  /// Opened, or opening, if it is.
  Future<T>? get current => _opening;

  Future<T> open() => _opening ??= _closing.then((_) => _open());

  /// Closes what is open, then runs [after] before any new opening.
  Future<void> close([Future<void> Function()? after]) {
    final closed = _opening;
    _opening = null;
    final closing = _closing.then((_) async {
      if (closed != null) await _close(await closed);
      await after?.call();
    });
    // A failed closing must not keep the next opening from happening.
    _closing = closing.catchError((_) {});
    return closing;
  }
}
