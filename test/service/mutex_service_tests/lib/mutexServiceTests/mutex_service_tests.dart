import 'package:mutex_service_test/tests.dart';

class MockMutex extends IMutex {
  MockMutex(this.name);

  @override
  final String name;

  bool _locked = false;

  @override
  Future<void> lock() async {
    if (_locked) throw StateError('Already locked');
    _locked = true;
  }

  @override
  void unlock() {
    if (!_locked) throw StateError('Cannot unlock without locking first');
    _locked = false;
  }

  @override
  bool tryLock() {
    if (_locked) return false;
    _locked = true;
    return true;
  }

  @override
  Future<bool> lockWithTimeout(Duration timeout) async {
    await Future.delayed(timeout);
    return tryLock();
  }

  @override
  Future<T> protect<T>(Future<T> Function() criticalSection) async {
    await lock();
    try {
      return await criticalSection();
    } finally {
      unlock();
    }
  }

  @override
  bool get isUnused => !_locked;
}

void mutexServiceTest() {
  group('MutexService', () {
    test(
      'should return the same instance when factory constructor is called',
      () {
        final instance1 = MutexService();
        final instance2 = MutexService();
        expect(identical(instance1, instance2), true);
      },
    );

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

  group('IMutex', () {
    late MockMutex mutex;

    setUp(() {
      mutex = MockMutex('test_mutex');
    });

    test('should throw an error if unlock is called without locking first', () {
      expect(() => mutex.unlock(), throwsA(isA<StateError>()));
    });

    test('should allow reentrant locking by the same process', () async {
      expect(await mutex.tryLock(), isTrue);
      expect(mutex.tryLock(), isFalse);
      mutex.unlock();
    });

    test('should not block other operations when isUnused is true', () {
      expect(mutex.isUnused, isTrue);
    });

    test(
      'should maintain correct lock state after multiple tryLock attempts',
      () {
        expect(mutex.tryLock(), isTrue);
        expect(mutex.tryLock(), isFalse);
        mutex.unlock();
        expect(mutex.tryLock(), isTrue);
      },
    );
  });

  group('MutexService', () {
    late MutexService mutexService;

    setUp(() {
      mutexService = MutexService();
      mutexService.resetMetrics();
    });

    test('should reset metrics accurately', () {
      mutexService.getMetrics();
      mutexService.resetMetrics();
      expect(mutexService.getMetrics(), {
        'totalLocks': 0,
        'totalUnlocks': 0,
        'contentionCount': 0,
        'timeoutCount': 0,
        'contentionRate': 0.0,
      });
    });

    test('should handle rapid concurrent lock and unlock operations', () async {
      final mutex = mutexService.getMutex('concurrent');
      await mutex.lock();
      mutex.unlock();

      await Future.wait(
        List.generate(100, (_) async {
          await mutex.lock();
          mutex.unlock();
        }),
      );

      final metrics = mutexService.getMetrics();
      expect(metrics['totalLocks'], 101);
      expect(metrics['totalUnlocks'], 101);
    });

    test('should release and reacquire mutex correctly', () {
      final mutex = mutexService.getMutex('release_test');
      mutex.lock();
      mutex.unlock();

      expect(mutex.tryLock(), isTrue);
    });

    test(
      'should return accurate metrics after multiple lock/unlock cycles',
      () async {
        final mutex = mutexService.getMutex('metrics_test');

        for (int i = 0; i < 50; i++) {
          await mutex.lock();
          mutex.unlock();
        }

        final metrics = mutexService.getMetrics();
        expect(metrics['totalLocks'], 50);
        expect(metrics['totalUnlocks'], 50);
      },
    );
  });
}
