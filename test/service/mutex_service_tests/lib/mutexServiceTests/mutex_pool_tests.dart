
import 'package:scaibu_mutex_lock/scaibu_mutex_lock.dart';
import 'package:test/test.dart';

void mutexPoolTests() {
  group('MutexPool', () {
    test('should return different mutexes for different names', () {
      final MutexService service = MutexService();
      final IMutex mutex1 = service.getMutex('test1');
      final IMutex mutex2 = service.getMutex('test2');

      expect(mutex1.name, 'test1');
      expect(mutex2.name, 'test2');
      expect(mutex1 != mutex2, true);
    });

    test('should reuse existing mutexes with the same name', () {
      final MutexService service = MutexService();
      final IMutex mutex1 = service.getMutex('reuse_test');
      final IMutex mutex2 = service.getMutex('reuse_test');

      expect(identical(mutex1, mutex2), true);
    });

    test('should properly release mutexes', () {
      final MutexService service = MutexService();
      final IMutex mutex = service.getMutex('release_test');
      service.releaseMutex('release_test');

      // Getting the mutex again should create a new instance
      final IMutex newMutex = service.getMutex('release_test');
      expect(identical(mutex, newMutex), false);
    });
  });
}
