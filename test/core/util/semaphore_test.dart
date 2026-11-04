import 'dart:async';

import 'package:awady_music/core/util/semaphore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Semaphore tests', () {
    test('limits maximum concurrency to specified permits', () async {
      final semaphore = Semaphore(2);
      var currentActive = 0;
      var peakActive = 0;
      final completed = <int>[];

      Future<void> task(int id) async {
        await semaphore.run(() async {
          currentActive++;
          if (currentActive > peakActive) {
            peakActive = currentActive;
          }
          await Future<void>.delayed(const Duration(milliseconds: 20));
          currentActive--;
          completed.add(id);
        });
      }

      await Future.wait([task(1), task(2), task(3), task(4), task(5)]);

      expect(peakActive, 2);
      expect(completed.length, 5);
      expect(semaphore.currentPermits, 0);
      expect(semaphore.queueLength, 0);
    });

    test('maintains FIFO order for waiting tasks', () async {
      final semaphore = Semaphore(1);
      final executionOrder = <int>[];

      Future<void> task(int id) async {
        await semaphore.run(() async {
          executionOrder.add(id);
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });
      }

      final futures = [task(1), task(2), task(3)];

      await Future.wait(futures);
      expect(executionOrder, [1, 2, 3]);
    });

    test('releases permit even when action throws', () async {
      final semaphore = Semaphore(1);

      expect(
        () => semaphore.run<void>(() async {
          throw Exception('Task failure');
        }),
        throwsA(isA<Exception>()),
      );

      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(semaphore.currentPermits, 0);

      // Should be able to acquire again immediately
      var ran = false;
      await semaphore.run(() async {
        ran = true;
      });
      expect(ran, isTrue);
    });

    test('manual acquire and release', () async {
      final semaphore = Semaphore(2);
      expect(semaphore.currentPermits, 0);

      await semaphore.acquire();
      expect(semaphore.currentPermits, 1);

      await semaphore.acquire();
      expect(semaphore.currentPermits, 2);

      var waiterAcquired = false;
      unawaited(
        semaphore.acquire().then((_) {
          waiterAcquired = true;
        }),
      );

      expect(semaphore.queueLength, 1);
      expect(waiterAcquired, isFalse);

      semaphore.release();
      await Future<void>.delayed(Duration.zero);
      expect(waiterAcquired, isTrue);
      expect(semaphore.queueLength, 0);

      semaphore.release();
      expect(semaphore.currentPermits, 1);
      semaphore.release();
      expect(semaphore.currentPermits, 0);
      // Extra release should not make currentPermits negative
      semaphore.release();
      expect(semaphore.currentPermits, 0);
    });
  });
}
