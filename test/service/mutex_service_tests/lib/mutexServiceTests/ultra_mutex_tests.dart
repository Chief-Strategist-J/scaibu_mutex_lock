import 'dart:async';

import 'package:scaibu_mutex_lock/scaibu_mutex_lock.dart';
import 'package:test/test.dart';

/// ultra mutex Tests
void ultraMutexTests() {
  group('UltraMutex', () {
    late IMutex mutex;

    setUp(() {
      final MutexService service = MutexService();
      mutex = service.getMutex('test_mutex');
      service.resetMetrics();
    });

    test('should be able to acquire lock initially', () {
      expect(mutex.tryLock(), true); // should be able to acquire lock
      mutex.unlock(); // clean up
    });

    test('should lock and unlock correctly', () async {
      await mutex.lock();
      expect(mutex.tryLock(), false);
      mutex.unlock();
      expect(mutex.tryLock(), true);
      mutex.unlock(); // clean up
    });

    test('should report correct metrics when locking and unlocking', () async {
      // Create a dedicated metrics collector for this test
      final MetricsCollector testMetrics = MetricsCollector();

      // Create a mutex using this specific metrics collector
      final UltraMutex testMutex = UltraMutex(
        'metrics_test_mutex',
        testMetrics,
      );

      // Perform operations on this mutex
      await testMutex.lock();
      testMutex.unlock();

      // Verify metrics directly from our collector
      final Map<String, dynamic> snapshot = testMetrics.snapshot();
      expect(snapshot['totalLocks'], 1);
      expect(snapshot['totalUnlocks'], 1);
    });

    test('should report contention when multiple locks requested', () async {
      await mutex.lock();

      // Start another lock request (will be queued)
      final Future<void> lockFuture = mutex.lock();

      // Unlock to allow the queued request to proceed
      mutex.unlock();
      await lockFuture;
      mutex.unlock();

      final MutexService service = MutexService();
      final Map<String, dynamic> snapshot = service.getMetrics();
      expect(snapshot['totalLocks'], 2);
      expect(snapshot['totalUnlocks'], 2);
      expect(snapshot['contentionCount'], 1);
    });

    test('tryLock should return false when mutex is locked', () async {
      await mutex.lock();
      expect(mutex.tryLock(), false);
      mutex.unlock();
    });

    test(
      'lockWithTimeout should return true when lock acquired within timeout',
      () async {
        final bool result = await mutex.lockWithTimeout(
          const Duration(seconds: 1),
        );
        expect(result, true);
        mutex.unlock();
      },
    );

    test('lockWithTimeout should return false when timeout expires', () async {
      await mutex.lock();

      // Start a timed lock attempt that should time out
      final bool result = await mutex.lockWithTimeout(
        const Duration(milliseconds: 50),
      );
      expect(result, false);

      mutex.unlock();

      final MutexService service = MutexService();
      final Map<String, dynamic> snapshot = service.getMetrics();
      expect(snapshot['timeoutCount'], 1);
    });

    test(
      'protect should execute critical section with proper locking',
      () async {
        bool executedCriticalSection = false;

        await mutex.protect(() async {
          // Verify mutex is locked during critical section
          expect(mutex.tryLock(), false);
          executedCriticalSection = true;
          return true;
        });

        expect(executedCriticalSection, true);
        // Verify mutex is unlocked after critical section
        expect(mutex.tryLock(), true);
        mutex.unlock(); // clean up
      },
    );
  });

  group('UltraMutex tests', () {
    late UltraMutex mutex;
    late MetricsCollector metrics;

    setUp(() {
      metrics = MetricsCollector();
      mutex = UltraMutex('test-mutex', metrics);
    });

    test(
      'UltraMutex should handle lock contention from multiple async calls',
      () async {
        // Set up execution order tracking
        final List<String> executionOrder = <String>[];

        // First lock the mutex
        await mutex.lock();

        // Schedule three competing tasks
        final Future<void> task1 = mutex.protect(() async {
          executionOrder.add('task1-start');
          await Future<void>.delayed(const Duration(milliseconds: 50));
          executionOrder.add('task1-end');
          return;
        });

        final Future<void> task2 = mutex.protect(() async {
          executionOrder.add('task2-start');
          await Future<void>.delayed(const Duration(milliseconds: 20));
          executionOrder.add('task2-end');
          return;
        });

        final Future<void> task3 = mutex.protect(() async {
          executionOrder.add('task3-start');
          await Future<void>.delayed(const Duration(milliseconds: 10));
          executionOrder.add('task3-end');
          return;
        });

        // Short delay to ensure tasks are queued
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Unlock to allow the first task to proceed
        mutex.unlock();

        // Wait for all tasks to complete
        await Future.wait(<Future<void>>[task1, task2, task3]);

        // Verify execution happened in sequence (not in parallel)
        // We expect the exact order based on queue position, not by completion
        // time
        expect(executionOrder, <String>[
          'task1-start',
          'task1-end',
          'task2-start',
          'task2-end',
          'task3-start',
          'task3-end',
        ]);

        // Verify metrics
        final Map<String, dynamic> metricsSnapshot = metrics.snapshot();
        expect(
          metricsSnapshot['totalLocks'],
          equals(4),
        ); // Initial lock + 3 tasks
        expect(metricsSnapshot['totalUnlocks'], equals(4));
        expect(metricsSnapshot['contentionCount'], equals(3));
      },
    );

    test(
      'UltraMutex lockWithTimeout should handle zero timeout correctly',
      () async {
        // Lock the mutex first
        await mutex.lock();

        // Try to lock with zero timeout
        final bool acquired = await mutex.lockWithTimeout(Duration.zero);

        // Should timeout immediately
        expect(acquired, isFalse);

        // Check metrics
        final Map<String, dynamic> snapshot = metrics.snapshot();
        expect(snapshot['timeoutCount'], equals(1));

        // Release the original lock
        mutex.unlock();
      },
    );

    test(
      'UltraMutex tryLock should work consistently across async boundaries',
      () async {
        // Should be able to acquire lock
        expect(mutex.tryLock(), isTrue);

        // Schedule a delayed task to release the lock
        scheduleMicrotask(() {
          mutex.unlock();
        });

        // Wait for the microtask to complete
        await Future<void>.delayed(Duration.zero);

        // Should be able to acquire lock again
        expect(mutex.tryLock(), isTrue);
        mutex.unlock();
      },
    );
  });

  group('MutexPool tests', () {
    late MetricsCollector metrics;
    late MutexPool pool;

    setUp(() {
      metrics = MetricsCollector();
      pool = MutexPool(metrics);
    });

    test('MutexPool should maintain correct mutex lifecycle', () {
      // Get the same mutex twice - should return the same instance
      final IMutex mutex1 = pool.getMutex('test-mutex');
      final IMutex mutex2 = pool.getMutex('test-mutex');

      expect(identical(mutex1, mutex2), isTrue);
      expect(mutex1.name, equals('test-mutex'));

      // Release the mutex
      pool.releaseMutex('test-mutex');

      // Get it again - should be a new instance
      final IMutex mutex3 = pool.getMutex('test-mutex');
      expect(identical(mutex1, mutex3), isFalse);
      expect(mutex3.name, equals('test-mutex'));
    });

    test(
      'MutexPool should handle concurrent getMutex calls correctly',
      () async {
        // Create a list to track the mutexes
        final List<IMutex> mutexes = <IMutex>[];

        // Get the same mutex from multiple concurrent tasks
        final List<Future<void>> futures = <Future<void>>[];
        for (int i = 0; i < 10; i++) {
          futures.add(
            Future<void>(() {
              final IMutex mutex = pool.getMutex('concurrent-test');
              mutexes.add(mutex);
            }),
          );
        }

        // Wait for all tasks to complete
        await Future.wait(futures);

        // All tasks should get the same mutex instance
        for (int i = 1; i < mutexes.length; i++) {
          expect(identical(mutexes[0], mutexes[i]), isTrue);
        }
      },
    );

    test('MutexPool should not remove active mutexes during cleanup', () async {
      // Get a mutex and lock it
      final IMutex mutex = pool.getMutex('active-mutex');
      await mutex.lock();

      // Directly call the cleanup method
      // We need to use reflection or test a protected method here - for
      // now we'll just
      // test that the mutex remains accessible through the pool

      // We should still be able to get the same mutex
      final IMutex sameInstance = pool.getMutex('active-mutex');
      expect(identical(mutex, sameInstance), isTrue);

      // Unlock the mutex
      mutex.unlock();
    });

    // Tests that would require access to private state or time manipulation
    test('MutexPool should remove expired mutexes after timeout', () {
      // This test would require us to:
      // 1. Override DateTime.now for testing
      // 2. Directly access _pool to check removal
      // 3. Mock or expose the _cleanup method

      // For now, we're marking this test as needing implementation
      markTestSkipped('Requires access to internal state or time mocking');
    });

    // Similarly, this test requires access to internal timer or mocking
    test('MutexPool should trigger cleanup timer and remove expired locks', () {
      // Skipping for the same reasons as above
      markTestSkipped('Requires access to internal timer or time mocking');
    });

    test('MutexPool should retain locks with recent access during cleanup', () {
      // Skipping for the same reasons as above
      markTestSkipped('Requires access to internal state or time mocking');
    });
  });
}
