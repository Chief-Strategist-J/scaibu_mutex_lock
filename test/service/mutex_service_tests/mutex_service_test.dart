
import 'lib/mutexServiceTests/mutex_pool_tests.dart';
import 'lib/mutexServiceTests/mutex_service_integration_tests.dart';
import 'lib/mutexServiceTests/mutex_service_tests.dart';
import 'lib/mutexServiceTests/ultra_mutex_tests.dart';

Future<void> main() async {
  mutexServiceTest();
  ultraMutexTests();
  mutexPoolTests();
  integrationTests();
}
