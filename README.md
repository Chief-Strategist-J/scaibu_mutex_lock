# Scaibu Open-Source Initiative

This is more than just an open-source project—it's a **call to action**. At **Scaibu**, we're on a mission to create powerful, innovative tools that empower developers worldwide—but we can't do it alone. **We need you. Right now.**

Your contributions—whether fixing a small bug, writing new code, or enhancing documentation—are **vital**. Each line of code you write brings us closer to transforming the developer ecosystem and building a future where technology is open, accessible, and driven by community collaboration.

At **Scaibu**, we **see you**, and we **value your work**. Every effort you make is rewarded, and your contributions will never go unnoticed. Join us and become part of a community that is building something **bigger than all of us**.

## 🌟 Why Contribute?

By contributing to **Scaibu**, you’re not just helping us—you’re investing in a movement. Here’s what’s in it for you:

- **Earn Reward Points**: For every meaningful contribution, you earn **points**—with **1,000 points = $1 USD**.
- **Recognition & Visibility**: Your name will be proudly featured on our official platform as a valued contributor.
- **Exclusive Access**: As we develop new advanced developer tools, active contributors will receive **premium access**—before anyone else.
- **Be Part of Something Bigger**: Your work directly impacts the open-source community and helps shape the future of development.

## 🤝 Help Us Grow

We believe in the **power of community**. Your support is **essential** in helping us grow and deliver cutting-edge tools. Whether you contribute code, identify bugs, or improve documentation—**every action matters**.

If you’re passionate about open-source development and want to make a **real difference**, now is the time to step up. **We can't do this without you.** Together, we will build something extraordinary.

## 💼 How It Works

1. **Contribute**: Help us grow by fixing bugs, writing new features, or improving documentation.
2. **Earn Points**: Each verified contribution earns you reward points.
3. **Redeem Rewards**: Use your points to unlock premium features on the **Scaibu official site** (currently in development).

## 🚀 Get Started

1. **Fork the Repository**: Click the `Fork` button to create a copy of this repository.
2. **Clone Your Fork**:

   ```bash
   git clone https://github.com/your-username/any-scaibu-package
   cd scaibu-package
   ```

3. **Create a Branch**:

   ```bash
   git checkout -b feature/your-feature
   ```

4. **Make Changes**: Implement your code or fix issues.

5. **Commit and Push**:

   ```bash
   git add .
   git commit -m "feat: add new feature"
   git push origin feature/your-feature
   ```

6. **Open a Pull Request (PR)**: Submit a PR to the `main` branch for review.

## 📞 Contact Us

If you have questions or want to collaborate directly, feel free to reach out. **We need your voice, your skills, and your passion. Together, we can make this happen.**

- [Scaibu Official Site](https://scaibu.co.in/public/)
- [Scaibu LinkedIn Profile](https://in.linkedin.com/company/scaibu)
- [Scaibu Medium Site](https://scaibu.medium.com/)
- [Book a Consultation](https://calendly.com/scaibu/one-on-one-consultation)

## 📞 Contact Me

I’m personally invested in this journey—and I’m here to support you. If you’re ready to make a difference, reach out to me directly. Let’s build something **incredible** together.

- [My LinkedIn Profile](https://www.linkedin.com/in/chiefj/)
- Email: chief.strategist.j@gmail.com (Phone: 09664920749)

---

**Jaydeep Wagh**  
Founder, Scaibu

## Core Concepts

### What is a Mutex?

A mutex (mutual exclusion) is a synchronization primitive that grants exclusive access to a shared resource or critical section of code. When a task acquires a mutex, all other tasks attempting to acquire the same mutex are blocked until the first task releases it. This ensures that shared resources are accessed by only one task at a time, preventing potential race conditions.

In Dart's asynchronous environment, mutexes are particularly valuable because they allow you to create "islands of synchronization" within otherwise concurrent code, enabling safe manipulation of shared state.

### When to Use Mutexes

Mutexes are essential in several scenarios:

1. **Shared Resource Access**: When multiple asynchronous operations need to access or modify the same resource (database connection, file, shared memory).

2. **Critical Sections**: When certain operations must be executed atomically without interruption.

3. **State Management**: When maintaining consistent application state across asynchronous operations.

4. **Rate Limiting**: When controlling the rate of operations like API calls to prevent overwhelming external services.

5. **Ordered Execution**: When operations must be executed in a specific order despite being launched concurrently.

## Core Features

### Simple Mutex Implementation

The basic `SimpleMutex` provides straightforward exclusive access control to resources. This implementation forms the foundation of the library's concurrency control mechanisms.

```dart
import 'package:mutex_library/mutex.dart';

// Create a mutex to protect a specific resource
final SimpleMutex mutex = SimpleMutex('userProfileResource');

// Check mutex status
print('Mutex Name: ${mutex.name}');
print('Is Available: ${mutex.isUnused}');
print('Current Queue Length: ${mutex.queueLength}');

// Try to acquire without blocking
if (mutex.tryLock()) {
try {
// Critical section - exclusive access guaranteed
UserProfile profile = await fetchUserProfile(userId);
profile.lastLoginDate = DateTime.now();
await saveUserProfile(profile);
print('Profile updated successfully');
} finally {
// Always release the lock when done to prevent deadlocks
mutex.unlock();
print('Mutex released');
}
} else {
// Handle case when lock is unavailable
print('Resource busy - profile update queued for later');
scheduleRetry(() => updateUserProfile(userId));
}
```

This example demonstrates how to create and use a basic mutex. The `SimpleMutex` class provides fundamental operations:
- Creating a named mutex to represent a specific resource
- Checking if the mutex is currently available
- Attempting to acquire the lock without blocking
- Properly releasing the lock using a try-finally pattern

### Mutex Service for Global Access

The `MutexService` provides a centralized way to access mutexes by name, ensuring that the same mutex instance is used across different parts of your application:

```dart
import 'package:mutex_library/mutex_service.dart';

// Get a mutex from the service (creates it if it doesn't exist)
final IMutex mutex = MutexService().getMutex('shared-resource');

// You can now use this mutex as needed
await mutex.lock();
try {
// Critical section
} finally {
mutex.unlock();
}

// Later in another part of your application
final IMutex sameMutex = MutexService().getMutex('shared-resource');
// This will return the same mutex instance, ensuring proper synchronization
```

The `MutexService` is particularly useful in large applications where multiple components need to access the same resources, as it ensures consistent mutex usage across the entire application.

### Locking Patterns

The library supports multiple locking approaches to suit different scenarios:

#### 1. Manual Lock/Unlock

For fine-grained control over lock acquisition and release, allowing you to manage exactly when the lock is acquired and released:

```dart
Future<void> updateConfiguration(Config config) async {
  final configMutex = MutexService().getMutex('app-configuration');

  print('Waiting to acquire configuration lock...');
  await configMutex.lock(); // This will wait until the lock is available
  print('Lock acquired, updating configuration');

  try {
    // Critical section operations - only one thread can be here at a time
    final currentConfig = await loadConfigFromDisk();
    currentConfig.merge(config);
    await validateConfiguration(currentConfig); // Might throw if invalid
    await writeConfigToDisk(currentConfig);
    await notifyConfigListeners();
    print('Configuration updated successfully');
  } catch (e) {
    print('Configuration update failed: $e');
    // Handle error - perhaps reverting to previous configuration
    await restorePreviousConfig();
  } finally {
    // Ensure lock is always released even if exceptions occur
    configMutex.unlock();
    print('Configuration lock released');
  }
}
```

This pattern gives you complete control over when the lock is acquired and released, which is useful when you need to perform setup or cleanup operations outside the locked section. The try-finally pattern ensures the lock is always released, even if an exception occurs.

#### 2. Automatic Protection

For cleaner code with automatic lock management, the `protect` method handles locking and unlocking automatically:

```dart
Future<PaymentResult> processPayment(Payment payment) async {
  final paymentMutex = MutexService().getMutex('payment-processor');

  // The protect method automatically acquires and releases the lock
  final result = await paymentMutex.protect(() async {
    print('Payment processing started for order ${payment.orderId}');

    // These operations will be protected by the mutex
    final account = await getAccount(payment.accountId);

    // Verify sufficient funds
    if (account.balance < payment.amount) {
      throw InsufficientFundsException('Not enough funds to process payment');
    }

    // Deduct payment amount
    account.balance -= payment.amount;
    await saveAccount(account);

    // Record transaction
    final transaction = Transaction(
        id: generateTransactionId(),
        accountId: payment.accountId,
        amount: payment.amount,
        timestamp: DateTime.now(),
        type: TransactionType.payment
    );
    await recordTransaction(transaction);

    print('Payment processed successfully');
    return PaymentResult(
        success: true,
        transactionId: transaction.id,
        timestamp: transaction.timestamp
    );
  });

  return result;
}
```

The `protect` method is more concise and less error-prone since it guarantees the lock will be released, even if an exception occurs during the protected operation. This is the recommended approach for most use cases.

#### 3. Non-blocking Lock Acquisition

For scenarios where waiting is undesirable, such as UI operations that shouldn't freeze the interface:

```dart
Future<void> refreshUserInterface() async {
  final uiMutex = MutexService().getMutex('ui-refresh');

  // Try to acquire the lock without blocking
  if (uiMutex.tryLock()) {
    try {
      print('Starting UI refresh');
      // Update UI components
      await loadDashboardData();
      await updateWidgets();
      await refreshVisuals();
      print('UI refresh complete');
    } finally {
      uiMutex.unlock();
      print('UI refresh lock released');
    }
  } else {
    // UI refresh is already in progress, skip this request
    print('UI refresh already in progress, skipping duplicate request');

    // Optionally, we could show a "refresh in progress" indicator to the user
    showRefreshInProgressIndicator();
  }
}
```

The `tryLock` method is useful when you want to attempt an operation only if the resource is immediately available. If the lock is already held, you can take alternative actions rather than waiting.

#### 4. Timeout-based Locking

To prevent indefinite waiting, which could lead to poor user experience or blocked resources:

```dart
Future<void> synchronizeWithServer() async {
  final syncMutex = MutexService().getMutex('server-sync');

  print('Attempting to start server synchronization...');

  // Try to acquire the lock with a timeout
  final acquired = await syncMutex.lockWithTimeout(Duration(seconds: 5));

  if (acquired) {
    try {
      print('Starting server synchronization');
      // Perform synchronization operations
      await uploadPendingChanges();
      await downloadServerUpdates();
      await reconcileConflicts();
      print('Synchronization complete');
    } catch (e) {
      print('Synchronization error: $e');
    } finally {
      syncMutex.unlock();
      print('Synchronization lock released');
    }
  } else {
    // Lock acquisition timed out
    print('Could not acquire sync lock within timeout period');
    print('Another synchronization is likely in progress');

    // Notify user and possibly schedule retry
    notifyUser('Synchronization delayed - will try again automatically');
    scheduleRetry(() => synchronizeWithServer(), delay: Duration(minutes: 2));
  }
}
```

The `lockWithTimeout` method allows you to set a maximum waiting time, after which the attempt to acquire the lock will fail rather than waiting indefinitely. This is essential for responsive applications where operations should not block for too long.

## Advanced Concurrency Features

### Read-Write Lock

A read-write lock permits multiple simultaneous read operations while ensuring exclusive write access. This pattern is particularly useful for resources that are read frequently but modified infrequently, such as configuration data or cached values.

```dart
import 'package:mutex_library/read_write_lock.dart';

class CacheManager {
  final Map<String, dynamic> _cache = {};
  final ReadWriteLock _lock = ReadWriteLock('cache-manager');

  // Multiple readers can access the cache simultaneously
  Future<T?> get<T>(String key) async {
    return await _lock.read(() async {
      print('Reading from cache: $key');
      await Future.delayed(Duration(milliseconds: 20)); // Simulate read time
      final value = _cache[key];
      print('Cache read complete for $key: ${value != null ? "Hit" : "Miss"}');
      return value as T?;
    });
  }

  // Writers get exclusive access - blocks all readers while writing
  Future<void> set<T>(String key, T value) async {
    await _lock.write(() async {
      print('Writing to cache: $key');
      await Future.delayed(Duration(milliseconds: 50)); // Simulate write time
      _cache[key] = value;
      print('Cache write complete for $key');
    });
  }

  // Example of a complex operation that updates multiple entries
  Future<void> batchUpdate(Map<String, dynamic> entries) async {
    await _lock.write(() async {
      print('Starting batch update of ${entries.length} entries');

      for (final entry in entries.entries) {
        _cache[entry.key] = entry.value;
        // Simulate processing time for each entry
        await Future.delayed(Duration(milliseconds: 10));
      }

      print('Batch update complete');
    });
  }
}

// Usage example
Future<void> demonstrateReadWriteLock() async {
  final cache = CacheManager();

  // Populate cache with initial values
  await cache.set('user_1', {'name': 'Alice', 'age': 30});
  await cache.set('user_2', {'name': 'Bob', 'age': 25});

  // Execute concurrent operations
  await Future.wait([
    // Multiple reads can happen in parallel
    cache.get<Map>('user_1'),
    cache.get<Map>('user_2'),
    cache.get<Map>('user_3'), // Cache miss

    // Write operations get exclusive access
    cache.set('user_3', {'name': 'Charlie', 'age': 35}),

    // More read operations
    cache.get<Map>('user_1'),

    // Batch update (exclusive access)
    cache.batchUpdate({
      'user_4': {'name': 'David', 'age': 40},
      'user_5': {'name': 'Eva', 'age': 22}
    })
  ]);

  print('All cache operations completed');
}
```

The read-write lock pattern significantly improves performance by allowing concurrent read access while still providing exclusive write access when needed. In the example above, multiple cache reads can execute simultaneously, but writes will temporarily block all reads to ensure consistency.

### Hierarchical Locking

Hierarchical locking ensures structured access to nested resources, preventing deadlocks and maintaining consistency. This is particularly useful when working with complex data structures like nested documents or tree-like data.
I'll continue the documentation from where it left off and add more details about the Mutex Library for Dart/Flutter.

```dart
  Future<void> recalculateDocumentStatistics(String docId) async {
  await Future.delayed(Duration(milliseconds: 200));
}

Future<void> updateDocumentVersion(String docId) async {
  await Future.delayed(Duration(milliseconds: 50));
}

Future<List<String>> getDocumentSections(String docId) async {
  await Future.delayed(Duration(milliseconds: 100));
  return ['section-1', 'section-2', 'section-3'];
}

Future<void> validateSectionContent(String docId, String sectionId) async {
  await Future.delayed(Duration(milliseconds: 150));
}

Future<void> markSectionAsPublished(String docId, String sectionId) async {
  await Future.delayed(Duration(milliseconds: 100));
}

Future<void> markDocumentAsPublished(String docId) async {
  await Future.delayed(Duration(milliseconds: 150));
}

Future<void> notifySubscribers(String docId, String event) async {
  await Future.delayed(Duration(milliseconds: 200));
}
}
```

Hierarchical locking ensures that multiple operations accessing nested resources don't conflict with each other. In the example, document-level locks are acquired before section-level locks, establishing a consistent locking order that prevents deadlocks while maintaining data integrity.

### Distributed Locking

The library extends beyond local process locking to distributed locking across multiple application instances. This is essential for applications running in clustered environments, microservices architectures, or distributed systems.

```dart
import 'package:mutex_library/distributed_mutex.dart';

class DistributedJobProcessor {
  final DistributedMutex _mutex;

  DistributedJobProcessor({required String redisUrl}) :
        _mutex = DistributedMutex(
            key: 'batch-job-processor',
            lockTimeoutSeconds: 300,  // 5 minutes
            redisConnectionString: redisUrl
        );

  Future<void> processBatchJob(String batchId) async {
    print('Attempting to process batch $batchId');

    final lockAcquired = await _mutex.tryLock();

    if (!lockAcquired) {
      print('Could not acquire distributed lock - batch $batchId is likely being processed by another instance');
      return;
    }

    try {
      print('Lock acquired, processing batch $batchId');

      // Fetch batch data
      final batchItems = await fetchBatchItems(batchId);
      print('Processing ${batchItems.length} items in batch $batchId');

      // Process each item
      final results = <String, String>{};
      for (final item in batchItems) {
        try {
          await processItem(item);
          results[item.id] = 'success';
        } catch (e) {
          results[item.id] = 'error: $e';
          print('Error processing item ${item.id}: $e');
        }

        // Keep the lock alive during long-running operations
        await _mutex.extendLock();
      }

      // Record batch completion
      await markBatchComplete(batchId, results);
      print('Batch $batchId processing complete');

    } catch (e) {
      print('Error during batch processing: $e');
      await markBatchFailed(batchId, e.toString());
    } finally {
      // Release the distributed lock
      await _mutex.unlock();
      print('Distributed lock released');
    }
  }

  // Simulated batch processing methods
  Future<List<BatchItem>> fetchBatchItems(String batchId) async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.generate(10, (i) => BatchItem(id: 'item-$i', data: 'Sample data $i'));
  }

  Future<void> processItem(BatchItem item) async {
    await Future.delayed(Duration(milliseconds: 200));
    print('Processed item ${item.id}');
  }

  Future<void> markBatchComplete(String batchId, Map<String, String> results) async {
    await Future.delayed(Duration(milliseconds: 250));
  }

  Future<void> markBatchFailed(String batchId, String error) async {
    await Future.delayed(Duration(milliseconds: 150));
  }
}

class BatchItem {
  final String id;
  final String data;

  BatchItem({required this.id, required this.data});
}
```

Distributed locking is particularly useful in cloud-based applications where multiple instances might need to coordinate resource access. The implementation uses Redis as a centralized lock manager, ensuring that only one application instance can process a specific batch job at a time.

### Timed Locking & Deadlock Detection

The library includes sophisticated deadlock detection and prevention mechanisms to ensure your application doesn't freeze due to unresolved lock contention.

```dart
import 'package:mutex_library/mutex_service.dart';
import 'package:mutex_library/deadlock_detector.dart';

class BankingSystem {
  final MutexService _mutexService = MutexService();
  final DeadlockDetector _deadlockDetector = DeadlockDetector();

  Future<void> transferFunds(String fromAccount, String toAccount, double amount) async {
    print('Preparing to transfer $amount from $fromAccount to $toAccount');

    // Register this operation with the deadlock detector
    final operationId = _deadlockDetector.registerOperation('transfer-$fromAccount-$toAccount');

    try {
      // Acquire lock for source account with timeout and deadlock detection
      final sourceMutex = _mutexService.getMutex('account-$fromAccount');
      final lockAcquired = await sourceMutex.lockWithTimeout(
          Duration(seconds: 5),
          onWaiting: () => _deadlockDetector.registerWaiting(operationId, 'account-$fromAccount')
      );

      if (!lockAcquired) {
        throw TimeoutException('Could not acquire lock for account $fromAccount within timeout');
      }

      _deadlockDetector.registerAcquired(operationId, 'account-$fromAccount');

      try {
        print('Lock acquired for source account $fromAccount');

        // Verify sufficient funds
        final sourceBalance = await getAccountBalance(fromAccount);
        if (sourceBalance < amount) {
          throw InsufficientFundsException('Insufficient funds in account $fromAccount');
        }

        // Acquire lock for destination account
        final destMutex = _mutexService.getMutex('account-$toAccount');
        final destLockAcquired = await destMutex.lockWithTimeout(
            Duration(seconds: 5),
            onWaiting: () => _deadlockDetector.registerWaiting(operationId, 'account-$toAccount')
        );

        if (!destLockAcquired) {
          throw TimeoutException('Could not acquire lock for account $toAccount within timeout');
        }

        _deadlockDetector.registerAcquired(operationId, 'account-$toAccount');

        try {
          print('Lock acquired for destination account $toAccount');

          // Perform the transfer
          await updateAccountBalance(fromAccount, -amount);
          await updateAccountBalance(toAccount, amount);

          // Record the transaction
          await recordTransaction(fromAccount, toAccount, amount);

          print('Transfer complete: $amount from $fromAccount to $toAccount');
        } finally {
          // Release destination account lock
          destMutex.unlock();
          _deadlockDetector.registerReleased(operationId, 'account-$toAccount');
          print('Destination account lock released');
        }
      } finally {
        // Release source account lock
        sourceMutex.unlock();
        _deadlockDetector.registerReleased(operationId, 'account-$fromAccount');
        print('Source account lock released');
      }
    } finally {
      // Operation complete
      _deadlockDetector.unregisterOperation(operationId);
    }
  }

  // Smart transfer that automatically determines lock acquisition order
  // to prevent deadlocks
  Future<void> smartTransferFunds(String account1, String account2, double amount) async {
    // Always acquire locks in a consistent order to prevent deadlocks
    final orderedAccounts = [account1, account2]..sort();

    final firstAccount = orderedAccounts[0];
    final secondAccount = orderedAccounts[1];

    print('Smart transfer using ordered locking: $firstAccount, then $secondAccount');

    // Acquire first account lock
    final firstMutex = _mutexService.getMutex('account-$firstAccount');
    await firstMutex.lock();

    try {
      print('Lock acquired for first account $firstAccount');

      // Acquire second account lock
      final secondMutex = _mutexService.getMutex('account-$secondAccount');
      await secondMutex.lock();

      try {
        print('Lock acquired for second account $secondAccount');

        // Determine transfer direction
        if (firstAccount == account1) {
          // Transfer from account1 to account2
          await doTransfer(account1, account2, amount);
        } else {
          // Transfer from account2 to account1
          await doTransfer(account2, account1, amount);
        }
      } finally {
        // Release second account lock
        secondMutex.unlock();
        print('Second account lock released');
      }
    } finally {
      // Release first account lock
      firstMutex.unlock();
      print('First account lock released');
    }
  }

  // Helper method to perform the actual transfer
  Future<void> doTransfer(String from, String to, double amount) async {
    final sourceBalance = await getAccountBalance(from);
    if (sourceBalance < amount) {
      throw InsufficientFundsException('Insufficient funds in account $from');
    }

    await updateAccountBalance(from, -amount);
    await updateAccountBalance(to, amount);
    await recordTransaction(from, to, amount);

    print('Transfer complete: $amount from $from to $to');
  }

  // Simulated banking operations
  Future<double> getAccountBalance(String accountId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return 1000.0; // Simulated balance
  }

  Future<void> updateAccountBalance(String accountId, double change) async {
    await Future.delayed(Duration(milliseconds: 150));
  }

  Future<void> recordTransaction(String fromAccount, String toAccount, double amount) async {
    await Future.delayed(Duration(milliseconds: 200));
  }
}

class InsufficientFundsException implements Exception {
  final String message;
  InsufficientFundsException(this.message);
  @override
  String toString() => 'InsufficientFundsException: $message';
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => 'TimeoutException: $message';
}
```

The deadlock detection system monitors lock acquisition patterns and can detect potential deadlocks before they occur. The `smartTransferFunds` method demonstrates a common technique to prevent deadlocks: always acquiring locks in a consistent order (in this case, alphabetical order of account IDs).

## Performance Considerations

### Benchmarking Different Mutex Implementations

To help you choose the right mutex implementation for your specific use case, the library includes a benchmarking tool that compares different implementations under various workloads:

```dart
import 'package:mutex_library/benchmark.dart';

void main() async {
  final benchmark = MutexBenchmark();

  print('Running mutex performance benchmarks...');

  // Run benchmarks with different configurations
  await benchmark.runBenchmark(
      name: 'Light Contention',
      mutexCount: 10,
      operationCount: 1000,
      concurrentOperations: 5,
      operationDurationMs: 5
  );

  await benchmark.runBenchmark(
      name: 'Heavy Contention',
      mutexCount: 3,
      operationCount: 1000,
      concurrentOperations: 20,
      operationDurationMs: 10
  );

  await benchmark.runBenchmark(
      name: 'Long Operations',
      mutexCount: 5,
      operationCount: 100,
      concurrentOperations: 10,
      operationDurationMs: 50
  );

  print('Benchmark results:');
  benchmark.printResults();
}
```

This benchmarking tool helps you understand the performance characteristics of different mutex implementations under various conditions, allowing you to make informed decisions about which implementation to use in your application.

### Memory Usage and Cleanup

The library includes mechanisms to manage memory usage and clean up unused mutexes:

```dart
import 'package:mutex_library/mutex_service.dart';

Future<void> monitorMutexUsage() async {
  final service = MutexService();

  // Get statistics on mutex usage
  final stats = service.getStatistics();
  print('Active mutexes: ${stats.activeMutexCount}');
  print('Total lock acquisitions: ${stats.totalLockAcquisitions}');
  print('Total lock timeouts: ${stats.totalLockTimeouts}');
  print('Average lock wait time: ${stats.averageLockWaitTimeMs}ms');

  // Clean up unused mutexes
  final removed = service.cleanupUnusedMutexes(Duration(minutes: 30));
  print('Removed $removed unused mutexes');

  // Monitor current contention
  final contendedMutexes = service.getHighContentionMutexes();
  for (final mutex in contendedMutexes) {
    print('High contention mutex: ${mutex.name}, queue length: ${mutex.queueLength}');
  }
}
```

Memory management is crucial, especially in long-running applications. The cleanup mechanism automatically removes mutexes that haven't been used for a specified period, preventing memory leaks.

## Integration with Flutter

### State Management

The mutex library integrates seamlessly with Flutter state management solutions like Provider and Riverpod:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mutex_library/mutex.dart';

class UserRepository extends ChangeNotifier {
  final SimpleMutex _mutex = SimpleMutex('user-repository');
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> fetchUser(String userId) async {
    await _mutex.protect(() async {
      // Fetch user data from API
      print('Fetching user $userId');
      final userData = await _fetchUserFromApi(userId);

      // Update local state
      _currentUser = userData;
      notifyListeners();

      // Cache user data
      await _cacheUserData(userData);
    });
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    await _mutex.protect(() async {
      if (_currentUser == null) {
        throw StateError('No user is currently logged in');
      }

      // Update user profile
      print('Updating user profile for ${_currentUser!.id}');
      final updatedUser = await _updateUserProfileApi(_currentUser!.id, updates);

      // Update local state
      _currentUser = updatedUser;
      notifyListeners();

      // Update cache
      await _cacheUserData(updatedUser);
    });
  }

  Future<User> _fetchUserFromApi(String userId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return User(id: userId, name: 'Test User', email: 'test@example.com');
  }

  Future<User> _updateUserProfileApi(String userId, Map<String, dynamic> updates) async {
    await Future.delayed(Duration(milliseconds: 700));
    return User(
        id: userId,
        name: updates['name'] ?? 'Test User',
        email: updates['email'] ?? 'test@example.com'
    );
  }

  Future<void> _cacheUserData(User user) async {
    await Future.delayed(Duration(milliseconds: 200));
    print('User data cached: ${user.id}');
  }
}

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

// Usage in a Flutter widget
class UserProfileWidget extends StatelessWidget {
  final String userId;

  const UserProfileWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
        builder: (context, userRepo, child) {
          return FutureBuilder(
              future: userRepo.fetchUser(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final user = userRepo.currentUser;
                if (user == null) {
                  return Text('User not found');
                }

                return Column(
                  children: [
                    Text('User Profile: ${user.name}'),
                    Text('Email: ${user.email}'),
                    ElevatedButton(
                        onPressed: () async {
                          await userRepo.updateUserProfile({
                            'name': 'Updated Name'
                          });
                        },
                        child: Text('Update Name')
                    )
                  ],
                );
              }
          );
        }
    );
  }
}
```

### Background Processing

The mutex library is particularly useful for managing background processes in Flutter applications:

```dart
import 'package:flutter/material.dart';
import 'package:mutex_library/mutex.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundSyncManager {
  static const String SYNC_TASK = 'background-sync-task';
  final SimpleMutex _mutex = SimpleMutex('background-sync');

  Future<void> initialize() async {
    await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: true
    );

    // Register periodic background sync task
    await Workmanager().registerPeriodicTask(
        'unique-sync-task-id',
        SYNC_TASK,
        frequency: Duration(hours: 1),
        constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: true
        )
    );
  }

  Future<void> runSync() async {
    print('Background sync requested');

    // Try to acquire the mutex with a timeout
    final acquired = await _mutex.lockWithTimeout(Duration(minutes: 5));

    if (!acquired) {
      print('Another sync is already in progress, skipping this one');
      return;
    }

    try {
      print('Starting background sync');

      // Perform sync operations
      await _syncUserData();
      await _syncAppSettings();
      await _syncOfflineChanges();

      print('Background sync completed successfully');
    } catch (e) {
      print('Background sync failed: $e');
    } finally {
      _mutex.unlock();
      print('Background sync mutex released');
    }
  }

  // Mock sync operations
  Future<void> _syncUserData() async {
    await Future.delayed(Duration(seconds: 2));
    print('User data synchronized');
  }

  Future<void> _syncAppSettings() async {
    await Future.delayed(Duration(seconds: 1));
    print('App settings synchronized');
  }

  Future<void> _syncOfflineChanges() async {
    await Future.delayed(Duration(seconds: 3));
    print('Offline changes synchronized');
  }
}

// Setup background callback
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('Background task started: $task');

    if (task == BackgroundSyncManager.SYNC_TASK) {
      final syncManager = BackgroundSyncManager();
      await syncManager.runSync();
    }

    return true;
  });
}
```

This integration ensures that multiple background tasks don't interfere with each other, preventing race conditions and maintaining data consistency even when the app is running in the background.

## Advanced Usage Patterns

### Adaptive Mutex with Exponential Backoff

For systems under high load, an adaptive mutex with exponential backoff can help manage contention:

```dart
import 'package:mutex_library/advanced_mutex.dart';

class ApiRateLimiter {
  final AdaptiveMutex _mutex = AdaptiveMutex(
      name: 'api-rate-limiter',
      initialBackoffMs: 50,
      maxBackoffMs: 5000,
      backoffFactor: 2.0
  );

  Future<T> makeApiCall<T>(Future<T> Function() apiCall) async {
    int attempts = 0;
    const maxAttempts = 5;

    while (attempts < maxAttempts) {
      attempts++;

      try {
        // Try to acquire the mutex with adaptive backoff
        final acquired = await _mutex.acquire();

        if (!acquired) {
          print('API rate limit exceeded, backing off (attempt $attempts)');
          continue;
        }

        try {
          // Execute the API call
          return await apiCall();
        } finally {
          // Release the mutex, indicating success
          _mutex.release(success: true);
        }
      } catch (e) {
        // Release the mutex, indicating failure
        _mutex.release(success: false);

        if (attempts >= maxAttempts) {
          print('Maximum retry attempts reached, giving up');
          rethrow;
        }

        print('API call failed, retrying: $e');
      }
    }

    throw Exception('API call failed after multiple attempts');
  }
}

// Usage example
Future<void> demonstrateAdaptiveMutex() async {
  final rateLimiter = ApiRateLimiter();

  // Make multiple API calls concurrently
  await Future.wait([
    rateLimiter.makeApiCall(() => fetchUserData('user-1')),
    rateLimiter.makeApiCall(() => fetchUserData('user-2')),
    rateLimiter.makeApiCall(() => fetchUserData('user-3')),
    rateLimiter.makeApiCall(() => fetchUserData('user-4')),
    rateLimiter.makeApiCall(() => fetchUserData('user-5')),
  ]);

  print('All API calls completed');
}

Future<Map<String, dynamic>> fetchUserData(String userId) async {
  await Future.delayed(Duration(milliseconds: 300));
  return {'id': userId, 'name': 'User $userId'};
}
```

The adaptive mutex automatically adjusts its backoff strategy based on the success or failure of operations, helping to manage API rate limits effectively.

### Mutex with Priority Queuing

For scenarios where certain operations should take precedence over others:

```dart
import 'package:mutex_library/priority_mutex.dart';

enum OperationPriority {
  low,
  medium,
  high,
  critical
}

class EmergencySystem {
  final PriorityMutex _mutex = PriorityMutex('emergency-system');

  Future<void> handleEmergency(String emergencyId, OperationPriority priority) async {
    print('Emergency $emergencyId received with priority: $priority');

    // Acquire the mutex with the specified priority
    await _mutex.lock(priority: priority);

    try {
      print('Handling emergency $emergencyId');

      // Perform emergency response operations
      await _dispatchFirstResponders(emergencyId);
      await _notifyAuthorities(emergencyId);
      await _logEmergencyEvent(emergencyId);

      print('Emergency $emergencyId handled successfully');
    } finally {
      _mutex.unlock();
      print('Emergency system mutex released');
    }
  }

  // Mock emergency operations
  Future<void> _dispatchFirstResponders(String emergencyId) async {
    await Future.delayed(Duration(milliseconds: 500));
    print('First responders dispatched for emergency $emergencyId');
  }

  Future<void> _notifyAuthorities(String emergencyId) async {
    await Future.delayed(Duration(milliseconds: 300));
    print('Authorities notified about emergency $emergencyId');
  }

  Future<void> _logEmergencyEvent(String emergencyId) async {
    await Future.delayed(Duration(milliseconds: 200));
    print('Emergency event $emergencyId logged');
  }
}

// Usage example
Future<void> demonstratePriorityMutex() async {
  final emergencySystem = EmergencySystem();

  // Create a mix of emergency events with different priorities
  await Future.wait([
    emergencySystem.handleEmergency('minor-flood-1', OperationPriority.low),
    emergencySystem.handleEmergency('traffic-accident-1', OperationPriority.medium),
    emergencySystem.handleEmergency('building-fire-1', OperationPriority.high),
    emergencySystem.handleEmergency('earthquake-1', OperationPriority.critical),
    emergencySystem.handleEmergency('minor-flood-2', OperationPriority.low),
    emergencySystem.handleEmergency('traffic-accident-2', OperationPriority.medium),
  ]);

  print('All emergencies handled');
}
```

The priority mutex ensures that critical operations are processed before less important ones, regardless of their order in the queue.

## Best Practices

### Mutex Naming Conventions

Consistent naming conventions help maintain clarity and prevent errors:

```dart
// Good practice: Use hierarchical naming with clear resource identification
final userProfileMutex = SimpleMutex('resource:user:profile:${userId}');
final documentMutex = SimpleMutex('resource:document:${docId}');
final systemConfigMutex = SimpleMutex('resource:config:system');

// Good practice: Use namespaces to group related mutexes
final dbConnectionMutex = SimpleMutex('db:connection:primary');
final apiRateLimitMutex = SimpleMutex('api:rate-limit:users');
final fileSystemMutex = SimpleMutex('fs:documents:${directoryPath}');
```

### Error Handling and Recovery

Proper error handling ensures that mutexes are always released, even in failure scenarios:

```dart
Future<void> processUserData(String userId) async {
  final mutex = SimpleMutex('user-data-${userId}');

  try {
    await mutex.lock();

    try {
      // Process user data
      await fetchAndProcessUserData(userId);
    } catch (e) {
      // Handle processing errors
      print('Error processing user data: $e');
      await logError('user-data-processing', e, userId);

      // Attempt recovery
      if (e is NetworkTimeoutException) {
        await retryWithBackoff(() => fetchAndProcessUserData(userId));
      } else if (e is ValidationException) {
        await notifyUserOfValidationIssue(userId, e);
      } else {
        // Unrecoverable error
        await markUserForManualReview(userId);
      }
    } finally {
      // Always release the mutex
      mutex.unlock();
    }
  } catch (e) {
    // Handle lock acquisition errors
    print('Could not acquire user data lock: $e');
    await scheduleRetry(() => processUserData(userId));
  }
}
```

### Monitoring and Logging

Comprehensive monitoring helps identify bottlenecks and performance issues:

```dart
import 'package:mutex_library/mutex_monitor.dart';

void configureMutexMonitoring() {
  final monitor = MutexMonitor();

  // Configure monitoring
  monitor.configure(
      logLockAcquisitions: true,
      logLockReleases: true,
      logTimeouts: true,
      logHighContentionEvents: true,
      contentionThreshold: 5,
      samplingRatePercent: 10,
      detailedLogging: true
  );

  // Register callbacks
  monitor.onHighContention((mutex, queueLength, waitTime) {
    print('HIGH CONTENTION: ${mutex.name}, queue: $queueLength, wait: ${waitTime}ms');
    logAnalyticsEvent('mutex_high_contention', {
      'mutex_name': mutex.name,
      'queue_length': queueLength,
      'wait_time_ms': waitTime
    });
  });

  monitor.onDeadlockDetected((mutexes) {
    print('DEADLOCK DETECTED: ${mutexes.map((m) => m.name).join(', ')}');
    logAnalyticsEvent('mutex_deadlock_detected', {
      'mutex_names': mutexes.map((m) => m.name).join(', ')
    });
    sendAlertToDevTeam('Deadlock detected in production');
  });

  // Start monitoring
  monitor.start();
}

// Mock analytics methods
void logAnalyticsEvent(String eventName, Map<String, dynamic> properties) {
  print('Analytics event: $eventName, properties: $properties');
}

void sendAlertToDevTeam(String message) {
  print('ALERT: $message');
}
```

## Conclusion

The Mutex Library for Dart/Flutter provides a comprehensive solution for managing concurrency in your applications. By implementing proper synchronization mechanisms, you can prevent race conditions, ensure data consistency, and build more reliable applications.

Key takeaways:

1. Mutexes are essential for protecting shared resources in concurrent environments.
2. The library offers a variety of mutex implementations to suit different use cases.
3. Advanced features like read-write locks, hierarchical locking, and distributed locking provide solutions for complex concurrency scenarios.
4. Integration with Flutter state management and background processing ensures seamless use in mobile applications.
5. Best practices like consistent naming conventions, proper error handling, and comprehensive monitoring help maintain application reliability.

By following the patterns and examples provided in this documentation, you can effectively manage concurrency in your Dart and Flutter applications, leading to more robust and reliable software.

## API Reference

The library includes the following key classes and interfaces:

- `IMutex`: The base interface for all mutex implementations
- `SimpleMutex`: A basic mutex implementation
- `ReadWriteLock`: A mutex that allows multiple readers but exclusive writers
- `PriorityMutex`: A mutex that processes lock requests based on priority
- `AdaptiveMutex`: A mutex with exponential backoff for high-contention scenarios
- `DistributedMutex`: A mutex that works across multiple application instances
- `MutexService`: A service for managing and accessing mutexes by name
- `DeadlockDetector`: A utility for detecting and preventing deadlocks
- `MutexMonitor`: A monitoring system for tracking mutex performance and issues

Each class provides specific methods and properties suited to its purpose, as demonstrated in the examples throughout this documentation.