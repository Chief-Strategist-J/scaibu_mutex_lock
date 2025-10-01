import 'package:scaibu_mutex_lock/service/storage/storage_engine.dart';

/// Represents the various states for the Storage BLoC.
///
/// These states capture different phases of interaction with storage,
/// including loading, success, error, and completion states.
///
/// Usage:
/// - `StorageInitial` represents the uninitialized state.
/// - `StorageLoading` indicates a pending storage operation.
/// - `ItemsLoaded` holds a list of items when retrieval is successful.
/// - `ItemLoaded` holds a single item when a specific retrieval is successful.
/// - `RawDataLoaded` holds untyped data for cases requiring raw responses.
/// - `StorageError` represents an error state with an associated message.
/// - `StorageActionCompleted` indicates successful completion of an action.
abstract class StorageState {}

/// Initial state when the storage process is uninitialized.
///
/// This is the starting point before any operation is triggered.
class StorageInitial extends StorageState {}

/// State indicating a storage operation is currently in progress.
///
/// Use this to represent loading indicators or ongoing asynchronous actions.
class StorageLoading extends StorageState {}

/// State representing successful loading of a list of items.
///
/// This is a generic class to accommodate any `StorableModel` type.
///

class ItemsLoaded<T extends StorableModel> extends StorageState {
  /// Constructs an [ItemsLoaded] state with the provided [items].
  ItemsLoaded(this.items);

  /// Parameters:
  /// - [T]: Type extending `StorableModel`.
  /// - [items]: List of loaded items.
  final List<T> items;
}

/// State representing successful loading of a single item.
///
/// Useful for retrieving and displaying a specific storage item.
///

class ItemLoaded<T extends StorableModel> extends StorageState {
  /// Constructs an [ItemLoaded] state with the provided [item].
  ItemLoaded(this.item);

  /// Parameters:
  /// - [T]: Type extending `StorableModel`.
  /// - [item]: The loaded item, nullable if not found.
  final T? item;
}

/// State representing successful loading of raw, untyped data.
///
/// Use this when the retrieved data is not strongly typed.

class RawDataLoaded extends StorageState {
  /// Constructs a [RawDataLoaded] state with the provided [data].
  RawDataLoaded(this.data);

  /// Parameters:
  /// - [data]: Dynamic raw data, which can be any type.
  final dynamic data;
}

/// State indicating an error occurred during a storage operation.
///
/// Use this to propagate error messages to the UI.
class StorageError extends StorageState {
  /// Constructs a [StorageError] state with the provided [message].
  StorageError(this.message);

  /// Parameters:
  /// - [message]: Descriptive error message.
  final String message;
}

/// State indicating the successful completion of a storage action.
///
/// Useful for CRUD operations like creation, update, or deletion.

class StorageActionCompleted extends StorageState {
  /// Constructs a [StorageActionCompleted] state with the provided [message].
  StorageActionCompleted(this.message);

  /// Parameters:
  /// - [message]: Confirmation message of the completed action.
  final String message;
}
