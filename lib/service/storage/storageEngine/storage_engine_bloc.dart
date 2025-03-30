import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:scaibu_mutex_lock/service/storage/storageEngine/storage_engine_event.dart';
import 'package:scaibu_mutex_lock/service/storage/storageEngine/storage_engine_state.dart';
import 'package:scaibu_mutex_lock/service/storage/storage_engine.dart';

/// Bloc for managing data operations
class StorageEngineBloc<T extends StorableModel>
    extends Bloc<StorageEvent, StorageState> {
  /// Bloc for managing data operations
  StorageEngineBloc() : super(StorageInitial()) {
    /// Handles the LoadItems event for fetching a list of stored items.
    on<LoadItems<T>>((
      final LoadItems<T> event,
      final Emitter<StorageState> emit,
    ) async {
      /// Emit loading state before fetching data
      emit(StorageLoading());
      try {
        /// Retrieve all stored items based on the provided tag and
        /// deserialization method
        final List<T> items = await _engine.getAllItems<T>(
          event.tag,
          event.fromJson,
        );

        /// Emit a success state with the retrieved items
        emit(ItemsLoaded<T>(items));
      } catch (e) {
        /// Emit an error state if an exception occurs
        emit(StorageError('Failed to load items: $e'));
      }
    });

    /// Handles the LoadItem event for fetching a single stored item by ID.
    on<LoadItem<T>>((
      final LoadItem<T> event,
      final Emitter<StorageState> emit,
    ) async {
      /// Emit loading state before fetching data
      emit(StorageLoading());
      try {
        /// Retrieve the stored item using tag, ID, and deserialization method
        ///
        final T? item = await _engine.getItem(
          event.tag,
          event.id,
          event.fromJson,
        );

        /// Emit a success state with the retrieved item
        emit(ItemLoaded<T>(item));
      } catch (e) {
        /// Emit an error state if an exception occurs
        emit(StorageError('Failed to load item: $e'));
      }
    });

    /// Handles the SaveItem event for saving a single item to storage.
    on<SaveItem<T>>((
      final SaveItem<T> event,
      final Emitter<StorageState> emit,
    ) async {
      try {
        /// Store the provided item in storage under the specified tag
        await _engine.setItem(event.tag, event.item);

        /// Emit a success state indicating the item was saved
        emit(StorageActionCompleted('Item saved successfully'));
      } catch (e) {
        /// Emit an error state if an exception occurs
        emit(StorageError('Failed to save item: $e'));
      }
    });

    /// Handles the SaveItems event for saving multiple items to storage.
    on<SaveItems<T>>((
      final SaveItems<T> event,
      final Emitter<StorageState> emit,
    ) async {
      try {
        /// Store the provided list of items in storage under the specified tag
        await _engine.setItems(event.tag, event.items);

        /// Emit a success state indicating the items were saved
        emit(StorageActionCompleted('Items saved successfully'));
      } catch (e) {
        /// Emit an error state if an exception occurs
        emit(StorageError('Failed to save items: $e'));
      }
    });

    /// Handles the DeleteItem event for removing a single item from storage.
    on<DeleteItem>((
      final DeleteItem event,
      final Emitter<StorageState> emit,
    ) async {
      try {
        /// Remove the specified item from storage using its tag and ID
        await _engine.removeItem(event.tag, event.id);

        /// Emit a success state indicating the item was deleted
        emit(StorageActionCompleted('Item deleted successfully'));
      } catch (e) {
        /// Emit an error state if an exception occurs
        emit(StorageError('Failed to delete item: $e'));
      }
    });

    /// Handles the DeleteItems event for removing multiple items from storage.
    on<DeleteItems>((
      final DeleteItems event,
      final Emitter<StorageState> emit,
    ) async {
      try {
        /// Remove multiple items from storage using their tag and IDs
        await _engine.removeItems(event.tag, event.ids);

        /// Emit a success state indicating the items were deleted
        emit(StorageActionCompleted('Items deleted successfully'));
      } catch (e) {
        /// Emit an error state if an exception occurs
        emit(StorageError('Failed to delete items: $e'));
      }
    });

    /// Handles the DeleteWhere event for conditionally removing items
    /// from storage.
    on<DeleteWhere<T>>((
      final DeleteWhere<T> event,
      final Emitter<StorageState> emit,
    ) async {
      try {
        /// Remove items that satisfy a given condition in the storage
        await _engine.removeWhere(event.tag, event.fromJson, event.condition);

        /// Emit a success state indicating the filtered items were deleted
        emit(StorageActionCompleted('Items deleted successfully'));
      } catch (e) {
        /// Emit an error state if an exception occurs
        emit(StorageError('Failed to delete items: $e'));
      }
    });

    /// Handles the WatchItems event for streaming real-time
    /// updates of stored items.
    on<WatchItems<T>>((
      final WatchItems<T> event,
      final Emitter<StorageState> emit,
    ) async {
      /// Generate a unique subscription key for tracking the stream
      final String subKey = 'watch_items_${event.tag}';

      /// Cancel any existing subscription before creating a new one
      await _subscriptions[subKey]?.cancel();

      /// Listen for updates to the list of items in storage
      final Stream<List<T>> stream = await _engine.watchItems(
        event.tag,
        event.fromJson,
      );

      /// Store the subscription and emit new data whenever updates occur
      _subscriptions[subKey] = stream.listen((final List<T> items) {
        emit(ItemsLoaded<T>(items));
      });
    });

    /// Handles the WatchItem event for streaming real-time updates of
    /// a specific item.
    on<WatchItem<T>>((
      final WatchItem<T> event,
      final Emitter<StorageState> emit,
    ) async {
      /// Generate a unique subscription key for tracking the
      /// stream of a specific item
      final String subKey = 'watch_item_${event.tag}_${event.id}';

      /// Cancel any existing subscription before creating a new one
      await _subscriptions[subKey]?.cancel();

      /// Listen for updates to the specific item in storage
      final Stream<T?> stream = await _engine.watchItem(
        event.tag,
        event.id,
        event.fromJson,
      );

      /// Store the subscription and emit new data whenever updates occur
      _subscriptions[subKey] = stream.listen((final T? item) {
        emit(ItemLoaded<T>(item));
      });
    });

    /// Handles the WatchFilteredItems event for streaming real-time updates
    /// of items that match a specific filter condition.
    on<WatchFilteredItems<T>>((
      final WatchFilteredItems<T> event,
      final Emitter<StorageState> emit,
    ) async {
      /// Generate a unique subscription key for tracking the filtered stream
      final String subKey = 'watch_filtered_${event.tag}';

      /// Cancel any existing subscription before creating a new one
      await _subscriptions[subKey]?.cancel();

      /// Await the stream that provides updates for filtered items in storage
      final Stream<List<T>> stream = await _engine.watchFilteredItems(
        event.tag,
        event.fromJson,
        event.filter,
      );

      /// Store the subscription and emit new data whenever updates occur
      _subscriptions[subKey] = stream.listen((final List<T> items) {
        emit(ItemsLoaded<T>(items));
      });
    });

    /// Handles the QueryItems event for fetching items from storage
    /// that match a specified filter condition.
    on<QueryItems<T>>((
      final QueryItems<T> event,
      final Emitter<StorageState> emit,
    ) async {
      /// Emit loading state before querying data
      emit(StorageLoading());
      try {
        /// Retrieve items from storage based on tag, deserialization
        /// method, and filter criteria
        final List<T> items = await _engine.queryItems(
          event.tag,
          event.fromJson,
          event.filter,
        );

        /// Emit a success state with the retrieved items
        emit(ItemsLoaded<T>(items));
      } catch (e) {
        /// Emit an error state if an exception occurs
        emit(StorageError('Failed to query items: $e'));
      }
    });

    /// Handles the ClearStorage event for clearing
    /// all stored data under a specific tag.
    on<ClearStorage>((
      final ClearStorage event,
      final Emitter<StorageState> emit,
    ) async {
      try {
        /// Clear all stored data under the specified tag
        await _engine.clearTag(event.tag);

        /// Emit a success state indicating storage has been cleared
        emit(StorageActionCompleted('Storage cleared successfully'));
      } catch (e) {
        /// Emit an error state if an exception occurs
        emit(StorageError('Failed to clear storage: $e'));
      }
    });

    /// Handles the SetRawData event for
    /// saving raw (unstructured) data in storage.
    on<SetRawData>((
      final SetRawData event,
      final Emitter<StorageState> emit,
    ) async {
      try {
        /// Store the provided raw data under the specified tag
        await _engine.setRawData(event.tag, event.data);

        /// Emit a success state indicating the raw data was saved
        emit(StorageActionCompleted('Raw data saved successfully'));
      } catch (e) {
        /// Emit an error state if an exception occurs
        emit(StorageError('Failed to save raw data: $e'));
      }
    });

    /// Handles the GetRawData event for retrieving
    /// raw (unstructured) data from storage.
    on<GetRawData>((
      final GetRawData event,
      final Emitter<StorageState> emit,
    ) async {
      /// Emit loading state before retrieving data
      emit(StorageLoading());
      try {
        /// Retrieve raw data stored under the specified tag
        final dynamic data = await _engine.getRawData(event.tag);

        /// Emit a success state with the retrieved raw data
        emit(RawDataLoaded(data));
      } catch (e) {
        /// Emit an error state if an exception occurs
        emit(StorageError('Failed to get raw data: $e'));
      }
    });

    /// Handles the WatchRawData event for
    /// streaming real-time updates of raw data.
    on<WatchRawData>((
      final WatchRawData event,
      final Emitter<StorageState> emit,
    ) async {
      /// Generate a unique subscription key for tracking the raw data stream
      final String subKey = 'watch_raw_${event.tag}';

      /// Cancel any existing subscription before creating a new one
      await _subscriptions[subKey]?.cancel();

      /// Await the stream that provides updates for raw data in storage
      final Stream<dynamic> stream = await _engine.watchRawData(event.tag);

      /// Store the subscription and emit new data whenever updates occur
      _subscriptions[subKey] = stream.listen((final dynamic data) {
        emit(RawDataLoaded(data));
      });
    });
  }

  /// Instance of LocalStorageEngine responsible for handling
  /// storage operations.
  /// This provides methods for saving, retrieving, querying,
  /// and watching stored data.
  final LocalStorageEngine _engine = LocalStorageEngine();

  /// A map to keep track of active subscriptions to data streams.
  /// The keys represent unique subscription identifiers
  /// (e.g., 'watch_item_{tag}'),
  /// while the values store the corresponding StreamSubscription objects.
  /// This ensures proper management of live data
  /// updates and prevents memory leaks.
  final Map<String, StreamSubscription<dynamic>> _subscriptions =
      <String, StreamSubscription<dynamic>>{};

  /// Overrides the `close` method to properly clean up resources
  /// before the BLoC instance is disposed.
  ///
  /// This ensures that all active stream subscriptions are canceled
  /// to prevent memory leaks and unexpected behaviors.
  @override
  Future<void> close() {
    /// Iterate over all active subscriptions and cancel each one.
    for (final StreamSubscription<dynamic> subscription
        in _subscriptions.values) {
      subscription.cancel();
    }

    /// Clear the subscription map to free up memory.
    _subscriptions.clear();

    /// Call the superclasses `close` method to complete the disposal process.
    return super.close();
  }
}
