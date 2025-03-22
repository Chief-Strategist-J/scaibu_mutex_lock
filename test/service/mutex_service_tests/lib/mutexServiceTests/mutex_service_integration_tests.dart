import 'dart:async';

import 'package:scaibu_mutex_lock/scaibu_mutex_lock.dart';
import 'package:test/test.dart';

Future<int> _concurrentOperation(final IMutex mutex, final int index) async =>
    mutex.protect(() async {
      // Simulate some work
      await Future<dynamic>.delayed(const Duration(milliseconds: 20));
      return index;
    });

/// integration Tests
void integrationTests() {
  group('MetricsCollector tests', () {
    late MetricsCollector metrics;

    setUp(() {
      metrics = MetricsCollector();
    });

    test('MetricsCollector should reset to zero correctly', () {
      // Increment metrics
      metrics
        ..incrementLocks()
        ..incrementLocks()
        ..incrementUnlocks()
        ..incrementContentions()
        ..incrementTimeouts();

      // Verify they were incremented
      final Map<String, dynamic> snapshot1 = metrics.snapshot();
      expect(snapshot1['totalLocks'], equals(2));
      expect(snapshot1['totalUnlocks'], equals(1));
      expect(snapshot1['contentionCount'], equals(1));
      expect(snapshot1['timeoutCount'], equals(1));

      // Reset metrics
      metrics.reset();

      // Verify all values are reset to 0
      final Map<String, dynamic> snapshot2 = metrics.snapshot();
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

    test('MetricsCollector should maintain accurate counts after '
        'concurrent updates', () async {
      const int iterations = 100;
      final List<Future<void>> tasks = <Future<void>>[];

      // Run concurrent increment operations
      for (int i = 0; i < iterations; i++) {
        tasks.add(
          Future<void>(() {
            metrics
              ..incrementLocks()
              ..incrementUnlocks()
              ..incrementContentions()
              ..incrementTimeouts();
          }),
        );
      }

      // Wait for all tasks to complete
      await Future.wait(tasks);

      // Check that all increments were recorded correctly
      final Map<String, dynamic> snapshot = metrics.snapshot();
      expect(snapshot['totalLocks'], equals(iterations));
      expect(snapshot['totalUnlocks'], equals(iterations));
      expect(snapshot['contentionCount'], equals(iterations));
      expect(snapshot['timeoutCount'], equals(iterations));
      expect(
        snapshot['contentionRate'],
        equals(1.0),
      ); // contentions/locks = 1.0
    });
  });
  group('Integration Tests', () {
    test('should handle concurrent lock operations correctly', () async {
      final MutexService service = MutexService()..resetMetrics();

      final IMutex mutex = service.getMutex('concurrent_test');
      assert(
        identical(mutex, service.getMutex('concurrent_test')),
        'Mutex instance mismatch: Expected the same mutex for "concurrent_test',
      );

      final List<Future<int>> futures = List<Future<int>>.generate(
        5,
        (final int i) => _concurrentOperation(mutex, i),
      );
      final List<int> results = await Future.wait(futures);

      expect(results.toSet(), <int>{0, 1, 2, 3, 4});

      final Map<String, dynamic> metrics = service.getMetrics();

      expect(metrics['totalLocks'], 5);
      expect(metrics['totalUnlocks'], 5);
    });

    test('should correctly handle multiple mutexes', () async {
      final MutexService service = MutexService();
      final IMutex mutex1 = service.getMutex('multi_test_1');
      final IMutex mutex2 = service.getMutex('multi_test_2');

      final Future<String> future1 = mutex1.protect(() async {
        await Future<dynamic>.delayed(const Duration(milliseconds: 50));
        return 'mutex1';
      });

      final Future<String> future2 = mutex2.protect(() async {
        await Future<dynamic>.delayed(const Duration(milliseconds: 50));
        return 'mutex2';
      });

      final List<String> results = await Future.wait(<Future<String>>[
        future1,
        future2,
      ]);
      expect(results.toSet(), <String>{'mutex1', 'mutex2'});
    });
  });
  group('Integration Tests', () {
    late MutexService service;

    setUp(() {
      // Use the singleton MutexService
      service = MutexService()..resetMetrics();
    });

    test(
      'Integration Tests should handle interleaved lock/unlock calls',
      () async {
        final IMutex mutex = service.getMutex('interleaved-test');
        final List<String> operations = <String>[];

        // Task 1 locks then unlocks after a delay
        Future<void> task1() async {
          await mutex.lock();
          operations.add('Task1-Lock');
          await Future<void>.delayed(const Duration(milliseconds: 50));
          mutex.unlock();
          operations.add('Task1-Unlock');
        }

        // Task 2 attempts to lock after a short delay
        Future<void> task2() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          await mutex.lock();
          operations.add('Task2-Lock');
          mutex.unlock();
          operations.add('Task2-Unlock');
        }

        // Run both tasks concurrently
        await Future.wait(<Future<void>>[task1(), task2()]);

        // Verify the operations happened in the expected order
        expect(
          operations,
          equals(<String>[
            'Task1-Lock',
            'Task1-Unlock',
            'Task2-Lock',
            'Task2-Unlock',
          ]),
        );
      },
    );

    test('Integration Tests should support nested locking scenarios', () async {
      final IMutex mutex1 = service.getMutex('nested-outer');
      final IMutex mutex2 = service.getMutex('nested-inner');
      final List<String> operations = <String>[];

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
        equals(<String>[
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
        final IMutex mutex1 = service.getMutex('order-1');
        final IMutex mutex2 = service.getMutex('order-2');
        final IMutex mutex3 = service.getMutex('order-3');
        final List<String> operations = <String>[];

        // Lock all three mutexes in sequence
        await mutex1.lock();
        await mutex2.lock();
        await mutex3.lock();

        // Create competing tasks that try to acquire the locks in the same
        // order
        Future<void> task1() async {
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
        }

        Future<void> task2() async {
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
        }

        // Schedule both tasks
        final Future<void> task1Future = task1();
        final Future<void> task2Future = task2();

        // Release the locks in reverse order
        await Future<void>.delayed(const Duration(milliseconds: 10));
        mutex3.unlock();
        mutex2.unlock();
        mutex1.unlock();

        // Wait for both tasks to complete
        await Future.wait(<Future<void>>[task1Future, task2Future]);

        // Verify order is preserved (one task completes all locks before the
        // other starts)
        final int task1Index = operations.indexOf('Task1-Lock1');
        final int task2Index = operations.indexOf('Task2-Lock1');

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
        final IMutex mutex1 = service.getMutex('deadlock-1');
        final IMutex mutex2 = service.getMutex('deadlock-2');

        // Use a completer to synchronize the start of the tasks
        final Completer<void> ready = Completer<void>();
        final List<String> completed = <String>[];

        // Task1 tries to acquire locks in order: mutex1 -> mutex2
        Future<void> task1() async {
          await ready.future;

          await mutex1.lockWithTimeout(const Duration(milliseconds: 500));
          completed.add('Task1-Lock1');

          // Small delay to increase chance of deadlock scenario
          await Future<void>.delayed(const Duration(milliseconds: 10));

          final bool gotLock2 = await mutex2.lockWithTimeout(
            const Duration(milliseconds: 500),
          );
          if (gotLock2) {
            completed.add('Task1-Lock2');
            mutex2.unlock();
          }

          mutex1.unlock();
          completed.add('Task1-Done');
        }

        // Task2 tries to acquire locks in order: mutex2 -> mutex1
        Future<void> task2() async {
          await ready.future;

          await mutex2.lockWithTimeout(const Duration(milliseconds: 500));
          completed.add('Task2-Lock2');

          // Small delay to increase chance of deadlock scenario
          await Future<void>.delayed(const Duration(milliseconds: 10));

          final bool gotLock1 = await mutex1.lockWithTimeout(
            const Duration(milliseconds: 500),
          );
          if (gotLock1) {
            completed.add('Task2-Lock1');
            mutex1.unlock();
          }

          mutex2.unlock();
          completed.add('Task2-Done');
        }

        // Start both tasks
        final List<Future<void>> futures = <Future<void>>[task1(), task2()];

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
        final IMutex mutex = service.getMutex('performance-test');
        const int iterations = 100;
        const int concurrency = 10;

        final Stopwatch stopwatch = Stopwatch()..start();

        // Function that acquires and releases the lock multiple times
        Future<void> worker() async {
          for (int i = 0; i < iterations; i++) {
            await mutex.lock();
            // Do minimal work
            mutex.unlock();
          }
        }

        // Start multiple concurrent workers
        final List<Future<void>> futures = List<Future<void>>.generate(
          concurrency,
          (_) => worker(),
        );

        // Wait for all workers to complete
        await Future.wait(futures);

        stopwatch.stop();

        // Verify metrics
        final Map<String, dynamic> metrics = service.getMetrics();
        expect(metrics['totalLocks'], equals(iterations * concurrency));
        expect(metrics['totalUnlocks'], equals(iterations * concurrency));

        // Performance assertions - adjust thresholds based on your system
        // This is just an example - you'll need to calibrate for your
        // environment
        final double opsPerSecond =
            (iterations * concurrency) / (stopwatch.elapsedMilliseconds / 1000);

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
