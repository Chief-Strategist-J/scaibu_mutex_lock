# Scaibu Mutex Lock Service Library

This library provides various locking mechanisms and utilities for efficient concurrency management in Dart applications.

## Features
- **Mutex Locking**: Implements different mutex strategies, including circuit breaker and priority-based locking.
- **Transaction Management**: Supports atomic transactions and event-driven execution.
- **Concurrency Utilities**: Includes resource pooling, read-write locks, and isolate-based execution for parallel processing.

## Installation
Ensure you have added this library to your Dart or Flutter project:

```yaml
# Add dependency if needed
# dependencies:
#   your_package_name:
```

Then, import the library in your project:

```dart
import 'package:your_package_name/service.dart';
```

## Usage
Example usage of a priority mutex:

```dart
import 'package:your_package_name/service.dart';

void main() {
  final priorityMutex = PriorityMutex();
  
  priorityMutex.acquire().then((lock) {
    try {
      print("Critical section");
    } finally {
      lock.release();
    }
  });
}
```

## File Structure
```
lib/service/
├── mutexLock/
│   ├── circuit_breaker_mutex.dart
│   ├── composed_lock.dart
│   ├── mutex_transaction.dart
│   ├── priority_mutex.dart
│   ├── read_write_lock.dart
│   ├── resource_pool.dart
├── atomic_execution.dart
├── atomic_lock.dart
├── awaiting_stream.dart
├── event_queue.dart
├── isolate_execution.dart
├── service.dart (export file)
```

## License
MIT License. Feel free to modify and use in your projects.