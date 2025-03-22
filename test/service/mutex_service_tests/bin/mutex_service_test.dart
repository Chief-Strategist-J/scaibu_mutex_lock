import 'package:mutex_service_test/mutex_service_test.dart';
import 'package:test/test.dart';
import 'package:scaibu_mutex_lock/scaibu_mutex_lock.dart';
import 'dart:async';

Future<void> main() async {
  group('MutexService', () {
    test('should return the same instance when factory constructor is called', () {
      final instance1 = MutexService();
      final instance2 = MutexService();
      expect(identical(instance1, instance2), true);
    });

    test('should provide access to mutexes by name', () {
      final service = MutexService();
      final mutex1 = service.getMutex('test1');
      final mutex2 = service.getMutex('test2');

      expect(mutex1, isNotNull);
      expect(mutex2, isNotNull);
      expect(mutex1 != mutex2, true);
      expect(mutex1.name, 'test1');
      expect(mutex2.name, 'test2');
    });

    test('should return same mutex instance for the same name', () {
      final service = MutexService();
      final mutex1 = service.getMutex('test');
      final mutex2 = service.getMutex('test');

      expect(identical(mutex1, mutex2), true);
    });

    test('should correctly track mutex operations', () async {
      // Create a separate metrics collector for testing
      final testMetrics = MetricsCollector();

      // Create a mutex that uses this metrics collector
      final mutex = UltraMutex('test_mutex', testMetrics);

      // Perform operations with the mutex
      await mutex.lock();
      mutex.unlock();

      // Check that metrics were recorded correctly
      final metrics = testMetrics.snapshot();
      expect(metrics['totalLocks'], 1);
      expect(metrics['totalUnlocks'], 1);
    });
  });

  group('UltraMutex', () {
    late IMetricsCollector metrics;
    late IMutex mutex;

    setUp(() {
      final service = MutexService();
      metrics = service.metrics;
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
      final testMetrics = MetricsCollector();

      // Create a mutex using this specific metrics collector
      final testMutex = UltraMutex('metrics_test_mutex', testMetrics);

      // Perform operations on this mutex
      await testMutex.lock();
      testMutex.unlock();

      // Verify metrics directly from our collector
      final snapshot = testMetrics.snapshot();
      expect(snapshot['totalLocks'], 1);
      expect(snapshot['totalUnlocks'], 1);
    });



    test('should report contention when multiple locks requested', () async {
      await mutex.lock();

      // Start another lock request (will be queued)
      final lockFuture = mutex.lock();

      // Unlock to allow the queued request to proceed
      mutex.unlock();
      await lockFuture;
      mutex.unlock();

      final service = MutexService();
      final snapshot = service.getMetrics();
      expect(snapshot['totalLocks'], 2);
      expect(snapshot['totalUnlocks'], 2);
      expect(snapshot['contentionCount'], 1);
    });

    test('tryLock should return false when mutex is locked', () async {
      await mutex.lock();
      expect(mutex.tryLock(), false);
      mutex.unlock();
    });

    test('lockWithTimeout should return true when lock acquired within timeout', () async {
      final result = await mutex.lockWithTimeout(Duration(seconds: 1));
      expect(result, true);
      mutex.unlock();
    });

    test('lockWithTimeout should return false when timeout expires', () async {
      await mutex.lock();

      // Start a timed lock attempt that should time out
      final result = await mutex.lockWithTimeout(Duration(milliseconds: 50));
      expect(result, false);

      mutex.unlock();

      final service = MutexService();
      final snapshot = service.getMetrics();
      expect(snapshot['timeoutCount'], 1);
    });

    test('protect should execute critical section with proper locking', () async {
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
    });
  });

  group('MutexPool', () {
    test('should return different mutexes for different names', () {
      final service = MutexService();
      final mutex1 = service.getMutex('test1');
      final mutex2 = service.getMutex('test2');

      expect(mutex1.name, 'test1');
      expect(mutex2.name, 'test2');
      expect(mutex1 != mutex2, true);
    });

    test('should reuse existing mutexes with the same name', () {
      final service = MutexService();
      final mutex1 = service.getMutex('reuse_test');
      final mutex2 = service.getMutex('reuse_test');

      expect(identical(mutex1, mutex2), true);
    });

    test('should properly release mutexes', () {
      final service = MutexService();
      final mutex = service.getMutex('release_test');
      service.releaseMutex('release_test');

      // Getting the mutex again should create a new instance
      final newMutex = service.getMutex('release_test');
      expect(identical(mutex, newMutex), false);
    });
  });

   integrationTests();
}



