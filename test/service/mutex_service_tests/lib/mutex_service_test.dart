import 'package:test/test.dart';
import 'package:scaibu_mutex_lock/scaibu_mutex_lock.dart';
import 'dart:async';

Future<int> _concurrentOperation(IMutex mutex, int index) async {
  return mutex.protect(() async {
    // Simulate some work
    await Future.delayed(Duration(milliseconds: 20));
    return index;
  });
}

void integrationTests() {
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
}
