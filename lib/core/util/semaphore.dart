import 'dart:async';

/// An asynchronous counting semaphore to limit concurrency.
class Semaphore {
  Semaphore(this.maxPermits)
    : assert(maxPermits > 0, 'maxPermits must be greater than zero');

  final int maxPermits;
  int _currentPermits = 0;
  final List<Completer<void>> _waiters = [];

  /// Number of active permits currently granted.
  int get currentPermits => _currentPermits;

  /// Number of callers waiting to acquire a permit.
  int get queueLength => _waiters.length;

  /// Acquires a permit, waiting if all permits are in use.
  Future<void> acquire() {
    if (_currentPermits < maxPermits) {
      _currentPermits++;
      return Future.value();
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    return completer.future;
  }

  /// Releases an acquired permit, allowing waiting callers to proceed.
  void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0).complete();
    } else {
      if (_currentPermits > 0) {
        _currentPermits--;
      }
    }
  }

  /// Runs [action] within an acquired permit and guarantees its release.
  Future<T> run<T>(Future<T> Function() action) async {
    await acquire();
    try {
      return await action();
    } finally {
      release();
    }
  }
}
