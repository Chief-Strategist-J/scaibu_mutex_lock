import 'package:mutex_service_test/tests.dart';

void mutexPoolTests() {
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
}
