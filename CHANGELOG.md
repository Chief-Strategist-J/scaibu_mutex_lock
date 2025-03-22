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