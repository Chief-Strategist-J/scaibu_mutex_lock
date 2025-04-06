# Changelog

## [1.0.0] - 2025-03-14
### Added
- Initial release with mutex locking mechanisms.
- Implements Circuit Breaker Mutex, Read-Write Lock, Priority Mutex, and Resource Pool.
- Supports atomic execution and isolate-based execution for concurrency management.
- Includes event queue and awaiting stream utilities.

## [1.0.5] - 2025-03-22
### Added
- Example usage in example/lib/circuit_breaker_example.dart to demonstrate how to use the CircuitBreakerMutex class.
- Unit tests for CircuitBreakerMutex to ensure reliability and correctness.
### Fixed
- Resolved a bug related to improper state handling in CircuitBreakerMutex that caused incorrect circuit reset behavior.

## [1.0.7] - 2025-03-30
### Added
- Implemented `StorageEngineBloc` for managing data operations using BLoC.
- Added support for fetching, saving, deleting, and querying stored items with typed generics (`T extends StorableModel`).
- Introduced event-driven architecture with event handling for:
    - Loading single and multiple items (`LoadItem`, `LoadItems`).
    - Saving single and multiple items (`SaveItem`, `SaveItems`).
    - Deleting items based on ID, multiple IDs, or conditions (`DeleteItem`, `DeleteItems`, `DeleteWhere`).
    - Streaming real-time updates for stored data (`WatchItem`, `WatchItems`, `WatchFilteredItems`).
    - Querying stored items based on filter conditions (`QueryItems`).
    - Managing raw data (`SetRawData`, `GetRawData`, `WatchRawData`).
    - Clearing storage under a specific tag (`ClearStorage`).
### Fixed
- Addressed potential memory leaks by ensuring all stream subscriptions are properly canceled and cleared.

## [1.0.9] - 2025-04-06
### Fixed
- Ensured correct cancellation and cleanup of stream subscriptions in `WatchItem<T>` event to prevent memory leaks and duplicate listeners.
- Added conditional checks to avoid BLoC method calls (`add(...)`) after closure, preventing potential runtime exceptions.
- Improved internal `_subscriptions` map management by consistently removing canceled entries.
