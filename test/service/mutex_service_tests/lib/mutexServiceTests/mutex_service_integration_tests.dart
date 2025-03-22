import 'package:mutex_service_test/tests.dart';

Future<int> _concurrentOperation(IMutex mutex, int index) async {
  return mutex.protect(() async {
    // Simulate some work
    await Future.delayed(Duration(milliseconds: 20));
    return index;
  });
}

void integrationTests() {
  group('MetricsCollector tests', () {
    late MetricsCollector metrics;

    setUp(() {
      metrics = MetricsCollector();
    });

    test('MetricsCollector should reset to zero correctly', () {
      // Increment metrics
      metrics.incrementLocks();
      metrics.incrementLocks();
      metrics.incrementUnlocks();
      metrics.incrementContentions();
      metrics.incrementTimeouts();

      // Verify they were incremented
      final snapshot1 = metrics.snapshot();
      expect(snapshot1['totalLocks'], equals(2));
      expect(snapshot1['totalUnlocks'], equals(1));
      expect(snapshot1['contentionCount'], equals(1));
      expect(snapshot1['timeoutCount'], equals(1));

      // Reset metrics
      metrics.reset();

      // Verify all values are reset to 0
      final snapshot2 = metrics.snapshot();
      expect(snapshot2['totalLocks'], equals(0));
      expect(snapshot2['totalUnlocks'], equals(0));
      expect(snapshot2['contentionCount'], equals(0));
      expect(snapshot2['timeoutCount'], equals(0));
      expect(snapshot2['contentionRate'], equals(0.0));
    });

    test('MetricsCollector should accurately report contention rate', () {
      // No locks - contention rate should be 0
      expect(metrics.snapshot()['contentionRate'], equals(0.0));

      // Add 10 locks, 4 contentions = 40% contention rate
      for (int i = 0; i < 10; i++) {
        metrics.incrementLocks();
      }
      for (int i = 0; i < 4; i++) {
        metrics.incrementContentions();
      }

      expect(metrics.snapshot()['contentionRate'], equals(0.4));

      // Add 10 more locks, still 4 contentions = 20% contention rate
      for (int i = 0; i < 10; i++) {
        metrics.incrementLocks();
      }

      expect(metrics.snapshot()['contentionRate'], equals(0.2));
    });

    test(
      'MetricsCollector should maintain accurate counts after concurrent updates',
      () async {
        const int iterations = 100;
        final List<Future<void>> tasks = [];

        // Run concurrent increment operations
        for (int i = 0; i < iterations; i++) {
          tasks.add(
            Future<void>(() {
              metrics.incrementLocks();
              metrics.incrementUnlocks();
              metrics.incrementContentions();
              metrics.incrementTimeouts();
            }),
          );
        }

        // Wait for all tasks to complete
        await Future.wait(tasks);

        // Check that all increments were recorded correctly
        final snapshot = metrics.snapshot();
        expect(snapshot['totalLocks'], equals(iterations));
        expect(snapshot['totalUnlocks'], equals(iterations));
        expect(snapshot['contentionCount'], equals(iterations));
        expect(snapshot['timeoutCount'], equals(iterations));
        expect(
          snapshot['contentionRate'],
          equals(1.0),
        ); // contentions/locks = 1.0
      },
    );
  });
  group('Integration Tests', () {
    test('should handle concurrent lock operations correctly', () async {
      final service = MutexService();
      service.resetMetrics();

      final mutex = service.getMutex('concurrent_test');
      assert(identical(mutex, service.getMutex('concurrent_test')));

      final futures = List.generate(5, (i) => _concurrentOperation(mutex, i));
      final results = await Future.wait(futures);

      expect(results.toSet(), {0, 1, 2, 3, 4});

      final metrics = service.getMetrics();
      print('Final metrics: $metrics');

      expect(metrics['totalLocks'], 5);
      expect(metrics['totalUnlocks'], 5);
    });

    test('should correctly handle multiple mutexes', () async {
      final service = MutexService();
      final mutex1 = service.getMutex('multi_test_1');
      final mutex2 = service.getMutex('multi_test_2');

      final future1 = mutex1.protect(() async {
        await Future.delayed(Duration(milliseconds: 50));
        return 'mutex1';
      });

      final future2 = mutex2.protect(() async {
        await Future.delayed(Duration(milliseconds: 50));
        return 'mutex2';
      });

      final results = await Future.wait([future1, future2]);
      expect(results.toSet(), {'mutex1', 'mutex2'});
    });
  });
  group('Integration Tests', () {
    late MutexService service;

    setUp(() {
      // Use the singleton MutexService
      service = MutexService();
      service.resetMetrics();
    });

    test(
      'Integration Tests should handle interleaved lock/unlock calls',
      () async {
        final mutex = service.getMutex('interleaved-test');
        final List<String> operations = [];

        // Task 1 locks then unlocks after a delay
        final task1 = () async {
          await mutex.lock();
          operations.add('Task1-Lock');
          await Future<void>.delayed(const Duration(milliseconds: 50));
          mutex.unlock();
          operations.add('Task1-Unlock');
        };

        // Task 2 attempts to lock after a short delay
        final task2 = () async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          await mutex.lock();
          operations.add('Task2-Lock');
          mutex.unlock();
          operations.add('Task2-Unlock');
        };

        // Run both tasks concurrently
        await Future.wait([task1(), task2()]);

        // Verify the operations happened in the expected order
        expect(
          operations,
          equals(['Task1-Lock', 'Task1-Unlock', 'Task2-Lock', 'Task2-Unlock']),
        );
      },
    );

    test('Integration Tests should support nested locking scenarios', () async {
      final mutex1 = service.getMutex('nested-outer');
      final mutex2 = service.getMutex('nested-inner');
      final List<String> operations = [];

      await mutex1.protect(() async {
        operations.add('Outer-Start');

        await mutex2.protect(() async {
          operations.add('Inner-Start');
          await Future<void>.delayed(const Duration(milliseconds: 20));
          operations.add('Inner-End');
        });

        operations.add('Outer-After-Inner');
        await Future<void>.delayed(const Duration(milliseconds: 10));
        operations.add('Outer-End');
      });

      // Verify operations were properly nested
      expect(
        operations,
        equals([
          'Outer-Start',
          'Inner-Start',
          'Inner-End',
          'Outer-After-Inner',
          'Outer-End',
        ]),
      );
    });

    test(
      'Integration Tests should preserve lock order across multiple mutexes',
      () async {
        final mutex1 = service.getMutex('order-1');
        final mutex2 = service.getMutex('order-2');
        final mutex3 = service.getMutex('order-3');
        final List<String> operations = [];

        // Lock all three mutexes in sequence
        await mutex1.lock();
        await mutex2.lock();
        await mutex3.lock();

        // Create competing tasks that try to acquire the locks in the same order
        final task1 = () async {
          await mutex1.lock();
          operations.add('Task1-Lock1');
          await mutex2.lock();
          operations.add('Task1-Lock2');
          await mutex3.lock();
          operations.add('Task1-Lock3');

          // Release in reverse order
          mutex3.unlock();
          mutex2.unlock();
          mutex1.unlock();
        };

        final task2 = () async {
          await mutex1.lock();
          operations.add('Task2-Lock1');
          await mutex2.lock();
          operations.add('Task2-Lock2');
          await mutex3.lock();
          operations.add('Task2-Lock3');

          // Release in reverse order
          mutex3.unlock();
          mutex2.unlock();
          mutex1.unlock();
        };

        // Schedule both tasks
        final task1Future = task1();
        final task2Future = task2();

        // Release the locks in reverse order
        await Future<void>.delayed(const Duration(milliseconds: 10));
        mutex3.unlock();
        mutex2.unlock();
        mutex1.unlock();

        // Wait for both tasks to complete
        await Future.wait([task1Future, task2Future]);

        // Verify order is preserved (one task completes all locks before the other starts)
        final task1Index = operations.indexOf('Task1-Lock1');
        final task2Index = operations.indexOf('Task2-Lock1');

        if (task1Index < task2Index) {
          expect(
            operations.indexOf('Task1-Lock3') < task2Index,
            isTrue,
            reason: 'Task1 should complete all locks before Task2 starts',
          );
        } else {
          expect(
            operations.indexOf('Task2-Lock3') < task1Index,
            isTrue,
            reason: 'Task2 should complete all locks before Task1 starts',
          );
        }
      },
    );

    test(
      'Integration Tests should prevent deadlocks in concurrent environments',
      () async {
        final mutex1 = service.getMutex('deadlock-1');
        final mutex2 = service.getMutex('deadlock-2');

        // Use a completer to synchronize the start of the tasks
        final ready = Completer<void>();
        final completed = <String>[];

        // Task1 tries to acquire locks in order: mutex1 -> mutex2
        final task1 = () async {
          await ready.future;

          await mutex1.lockWithTimeout(const Duration(milliseconds: 500));
          completed.add('Task1-Lock1');

          // Small delay to increase chance of deadlock scenario
          await Future<void>.delayed(const Duration(milliseconds: 10));

          final gotLock2 = await mutex2.lockWithTimeout(
            const Duration(milliseconds: 500),
          );
          if (gotLock2) {
            completed.add('Task1-Lock2');
            mutex2.unlock();
          }

          mutex1.unlock();
          completed.add('Task1-Done');
        };

        // Task2 tries to acquire locks in order: mutex2 -> mutex1
        final task2 = () async {
          await ready.future;

          await mutex2.lockWithTimeout(const Duration(milliseconds: 500));
          completed.add('Task2-Lock2');

          // Small delay to increase chance of deadlock scenario
          await Future<void>.delayed(const Duration(milliseconds: 10));

          final gotLock1 = await mutex1.lockWithTimeout(
            const Duration(milliseconds: 500),
          );
          if (gotLock1) {
            completed.add('Task2-Lock1');
            mutex1.unlock();
          }

          mutex2.unlock();
          completed.add('Task2-Done');
        };

        // Start both tasks
        final futures = [task1(), task2()];

        // Release the synchronization point
        ready.complete();

        // Wait for both tasks with a timeout
        await Future.wait(futures).timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            fail('Deadlock detected: tasks did not complete within timeout');
          },
        );

        // Both tasks should complete
        expect(completed.contains('Task1-Done'), isTrue);
        expect(completed.contains('Task2-Done'), isTrue);
      },
    );

    test(
      'Integration Tests should verify performance under heavy contention',
      () async {
        final mutex = service.getMutex('performance-test');
        const iterations = 100;
        const concurrency = 10;

        final stopwatch = Stopwatch()..start();

        // Function that acquires and releases the lock multiple times
        Future<void> worker() async {
          for (int i = 0; i < iterations; i++) {
            await mutex.lock();
            // Do minimal work
            mutex.unlock();
          }
        }

        // Start multiple concurrent workers
        final futures = List.generate(concurrency, (_) => worker());

        // Wait for all workers to complete
        await Future.wait(futures);

        stopwatch.stop();

        // Verify metrics
        final metrics = service.getMetrics();
        expect(metrics['totalLocks'], equals(iterations * concurrency));
        expect(metrics['totalUnlocks'], equals(iterations * concurrency));

        // Performance assertions - adjust thresholds based on your system
        // This is just an example - you'll need to calibrate for your environment
        final opsPerSecond =
            (iterations * concurrency) / (stopwatch.elapsedMilliseconds / 1000);
        print('Lock/unlock operations per second: $opsPerSecond');

        // Very conservative threshold that should pass on most systems
        expect(
          opsPerSecond,
          greaterThan(100),
          reason: 'Lock/unlock performance is below acceptable threshold',
        );
      },
    );
  });
}
