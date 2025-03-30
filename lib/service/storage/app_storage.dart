import 'package:scaibu_mutex_lock/service/storage/storageEngine/storage_engine_bloc.dart';
import 'package:scaibu_mutex_lock/service/storage/storage_engine.dart';

/// A singleton class that manages the application's storage operations.
///
/// This class provides a centralized way to handle storage-related tasks
/// by utilizing the `StorageEngineBloc` for reactive state management and
/// the `LocalStorageEngine` for interacting with local storage mechanisms.
///
/// ### Design:
/// - Implements the singleton pattern to ensure a single instance of
///   `AppStorage` throughout the app's lifecycle.
/// - Provides a `dispose()` method to properly release resources and
///   prevent memory leaks.
///
/// ### Usage:
/// ```dart
/// final appStorage = AppStorage();
/// appStorage.storageBloc.add(SomeStorageEvent());
/// ```
///
/// ### Responsibilities:
/// - Manages the `StorageEngineBloc` instance for handling storage events.
/// - Provides access to the `LocalStorageEngine` for local data management.
/// - Ensures proper cleanup of resources when the `dispose()` method is called.
///
/// Example:
/// ```dart
/// final appStorage = AppStorage();
/// appStorage.dispose(); // Clean up resources when no longer needed.
/// ```
class AppStorage<T extends StorableModel> {
  /// Factory constructor to return the same instance of [AppStorage].
  factory AppStorage() => AppStorage<T>._internal();

  /// Private named constructor for internal use.
  AppStorage._internal();

  /// Manages storage-related state using the BLoC pattern.
  final StorageEngineBloc<T> storageBloc = StorageEngineBloc<T>();

  /// Handles low-level local storage operations.
  final LocalStorageEngine storageEngine = LocalStorageEngine();

  /// Call this method when [AppStorage] is no longer needed to ensure
  /// proper cleanup and avoid memory leaks.
  Future<void> dispose() async {
    await storageBloc.close();
    await storageEngine.dispose();
  }
}
