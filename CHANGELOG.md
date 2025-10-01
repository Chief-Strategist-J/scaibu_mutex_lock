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

## [1.0.10] - 2025-10-01
### Added
- **Searching utilities** under `lib/service/searching/`
  - `find_all_duplicates.dart`
  - `find_all_peak_elements.dart`
  - `find_any_peak_element.dart`
  - `find_elements_repeated_exactly_k_times.dart`
  - `find_element_with_max_frequency.dart`
  - `find_first_duplicate_by_index.dart`
  - `find_kth_largest.dart`
  - `find_k_th_smallest.dart`
  - `find_largest_in_rotated_sorted_array.dart`
  - `find_majority_elements.dart`
  - `find_minimum_in_rotated_sorted_array.dart`
  - `find_missing_element.dart`
  - `find_single_unique.dart`
  - `find_smallest_element.dart`
  - `find_unique_among_repeats.dart`
  - `has_duplicates.dart`
  - `find_largest_element.dart`

- **Storage layer enhancements**
  - Added `app_storage.dart` for generic storage handling.
  - Introduced `storage_engine.dart` with BLoC pattern support.
  - Added `storageEngine/` sub-module with:
    - `storage_engine_bloc.dart`
    - `storage_engine_event.dart`
    - `storage_engine_state.dart`

- **TreeCraft repository**
  - Introduced `tree_repository/` for tree-based data structures.
  - Added `tree_mappable.dart` under `model/`.
  - Added `generic_tree_node.dart` under `service/`.

### Changed
- Reorganized `lib/` structure:
  - Core mutex handling in `core/mutex_service.dart`
  - Lock implementations moved to `src/lock/`
  - Mutex implementations moved to `src/mutex/`
  - Async utilities under `src/stream/`
  - Shared resources under `src/utils/`
- Ensured `scaibu_mutex_lock.dart` acts as a clean public API entrypoint.

### Deprecated
- `lib/main.dart` kept temporarily for compatibility but scheduled for removal.
- `lib/example/lib/main.dart` (will be migrated to top-level `example/` folder in future release).

### Fixed
- Improved internal naming consistency (`transaction_mutex.dart` instead of `mutex_transaction.dart`).
- Resolved deep nesting in earlier `treeCraft` and `mutexLock` directories.
