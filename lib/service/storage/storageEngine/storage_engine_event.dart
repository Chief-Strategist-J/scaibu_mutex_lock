import 'package:scaibu_mutex_lock/service/storage/storage_engine.dart';

/// Base class for all storage-related events in the Bloc.
///
/// Each event is a representation of a user action that interacts with
/// the storage engine. These events are dispatched to the Bloc to:
/// - Retrieve data from storage.
/// - Persist data to storage.
/// - Observe changes in stored data.
/// - Perform bulk operations like saving or deleting.
/// - Manipulate raw data directly.
///
/// This abstraction allows the Bloc to manage data consistently while
/// keeping the UI layer decoupled from the underlying storage mechanism.
abstract class StorageEvent {}

/// Event to load multiple items from storage.
///
/// This event triggers the retrieval of a collection of objects
/// stored under a specific [tag]. The objects are deserialized
/// using the provided [fromJson] method.
///
/// - [T] should be a subclass of `StorableModel` to ensure compatibility
///   with the storage system.
/// - [tag] is a unique identifier representing a storage collection
///   (e.g., "users", "orders").
/// - [fromJson] is a function that converts a JSON map into an
///   instance of type [T].
///
/// Example usage:
/// ```dart
/// bloc.add(LoadItems<User>(
///   'users',
///   (json) => User.fromJson(json),
/// ));
/// ```
class LoadItems<T extends StorableModel> extends StorageEvent {
  /// Constructs a `LoadItems` event.
  ///
  /// - Requires a [tag] to specify the data source.
  /// - Requires a [fromJson] method to deserialize objects.
  LoadItems({required this.tag, required this.fromJson});

  /// Storage key to identify the data collection.
  final String tag;

  /// Function to deserialize a JSON map into an object of type [T].
  final T Function(Map<String, dynamic>) fromJson;
}

/// Event to load a single item from storage.
///
/// This event is similar to [LoadItems] but retrieves a specific object
/// identified by its unique [id].
///
/// - [T] must extend `StorableModel`.
/// - [tag] identifies the storage collection.
/// - [id] represents the unique identifier of the object.
/// - [fromJson] deserializes the JSON map into an object.
///
/// Example usage:
/// ```dart
/// bloc.add(LoadItem<User>(
///   'users',
///   'user_123',
///   (json) => User.fromJson(json),
/// ));
/// ```
class LoadItem<T extends StorableModel> extends StorageEvent {
  /// Constructs a `LoadItem` event.
  ///
  /// - Requires [tag] to specify the data source.
  /// - Requires [id] to fetch a specific item.
  /// - Requires a [fromJson] method for deserialization.
  LoadItem({required this.tag, required this.id, required this.fromJson});

  /// Storage key for the collection containing the item.
  final String tag;

  /// Unique identifier of the item to retrieve.
  final String id;

  /// Function to deserialize a JSON map into an object of type [T].
  final T Function(Map<String, dynamic>) fromJson;
}

/// Event to save a single item to storage.
///
/// This event stores an object under a specified [tag].
///
/// - [T] must extend `StorableModel`.
/// - [tag] is a unique identifier for the storage location.
/// - [item] is the object to be stored.
///
/// Example usage:
/// ```dart
/// bloc.add(SaveItem<User>(
///   'users',
///   User(id: '123', name: 'John Doe'),
/// ));
/// ```
class SaveItem<T extends StorableModel> extends StorageEvent {
  /// Constructs a `SaveItem` event.
  ///
  /// - Requires a [tag] for item categorization.
  /// - Accepts an [item] object to store.
  SaveItem({required this.tag, required this.item});

  /// Storage key representing the collection to save the item in.
  final String tag;

  /// Object to be saved, must be a subclass of `StorableModel`.
  final T item;
}

/// Event to save multiple items to storage.
///
/// Similar to [SaveItem], but allows batch storage for performance
/// optimization.
///
/// - [T] must extend `StorableModel`.
/// - [tag] is the identifier for the storage collection.
/// - [items] is a list of objects to be stored.
///
/// Example usage:
/// ```dart
/// bloc.add(SaveItems<User>(
///   'users',
///   [User(id: '123'), User(id: '456')],
/// ));
/// ```
class SaveItems<T extends StorableModel> extends StorageEvent {
  /// Constructs a `SaveItems` event.
  ///
  /// - Requires a [tag] to identify the collection.
  /// - Accepts a list of [items] to store.
  SaveItems({required this.tag, required this.items});

  /// Storage key identifying the collection to save items in.
  final String tag;

  /// List of items to be stored, each implementing `StorableModel`.
  final List<T> items;
}

/// Event to delete a single item from storage.
///
/// - [tag] identifies the storage collection.
/// - [id] is the unique identifier of the item to delete.
///
/// Example usage:
/// ```dart
/// bloc.add(DeleteItem('users', 'user_123'));
/// ```
class DeleteItem extends StorageEvent {
  /// Constructs a `DeleteItem` event.
  ///
  /// - Requires [tag] to locate the collection.
  /// - Requires [id] to specify the item for deletion.
  DeleteItem({required this.tag, required this.id});

  /// Storage key identifying the collection to delete from.
  final String tag;

  /// Unique identifier of the item to be deleted.
  final String id;
}

/// Event to delete multiple items from storage.
///
/// - [tag] identifies the storage collection.
/// - [ids] is a list of unique identifiers for items to delete.
///
/// Example usage:
/// ```dart
/// bloc.add(DeleteItems('users', ['user_123', 'user_456']));
/// ```
class DeleteItems extends StorageEvent {
  /// Constructs a `DeleteItems` event.
  ///
  /// - Requires [tag] for collection identification.
  /// - Accepts [ids] to delete multiple items.
  DeleteItems({required this.tag, required this.ids});

  /// Storage key identifying the collection to delete from.
  final String tag;

  /// List of unique item identifiers to be deleted.
  final List<String> ids;
}

/// Event to set raw (unstructured) data directly in storage.
///
/// Useful for storing JSON objects or other raw data formats without
/// requiring deserialization.
///
/// - [tag] identifies the storage location.
/// - [data] is the raw data to be stored.
///
/// Example usage:
/// ```dart
/// bloc.add(SetRawData('settings', {'theme': 'dark'}));
/// ```
class SetRawData extends StorageEvent {
  /// Constructs a `SetRawData` event.
  ///
  /// - Requires [tag] to identify the storage location.
  /// - Accepts [data] as the value to store.
  SetRawData({required this.tag, required this.data});

  /// Storage key for the location where the raw data will be stored.
  final String tag;

  /// Raw data to be stored (can be any data type).
  final dynamic data;
}

/// Event to retrieve raw data from a specified storage collection.
///
/// - [tag] identifies the collection to retrieve from.
///
/// Example usage:
/// ```dart
/// bloc.add(GetRawData('settings'));
/// ```
class GetRawData extends StorageEvent {
  /// Constructs a `GetRawData` event.
  ///
  /// - Requires [tag] to identify the data source.
  GetRawData({required this.tag});

  /// Storage key representing the location to fetch raw data from.
  final String tag;
}

/// Event to delete items from storage that match a specified condition.
///
/// This event is used to remove entries from the storage system
/// where the provided [condition] evaluates to `true`.
///
/// [T] represents a model type that extends [StorableModel].

class DeleteWhere<T extends StorableModel> extends StorageEvent {
  /// Constructs a [DeleteWhere] event.
  DeleteWhere({
    required this.tag,
    required this.fromJson,
    required this.condition,
  });

  /// Parameters:
  /// - [tag]: A unique identifier for the storage collection.

  final String tag;

  /// - [fromJson]: A function to convert JSON data into the model.
  final T Function(Map<String, dynamic>) fromJson;

  /// - [condition]: A predicate function to determine which items to delete.
  final bool Function(T item) condition;
}

/// Event to watch all items in a specified storage collection.
///
/// This event listens for changes to all items stored under a given [tag]
/// and triggers updates when the data changes.
///
/// [T] represents a model type that extends [StorableModel].
///

class WatchItems<T extends StorableModel> extends StorageEvent {
  /// Constructs a [WatchItems] event.
  WatchItems({required this.tag, required this.fromJson});

  /// Parameters:
  /// - [tag]: A unique identifier for the storage collection.

  final String tag;

  /// - [fromJson]: A function to convert JSON data into the model.
  final T Function(Map<String, dynamic>) fromJson;
}

/// Event to watch a specific item in the storage system.
///
/// This event listens for changes to a single item identified by [id]
/// in the collection specified by [tag].
///
/// [T] represents a model type that extends [StorableModel].
///

class WatchItem<T extends StorableModel> extends StorageEvent {
  /// Constructs a [WatchItem] event.
  WatchItem({required this.tag, required this.id, required this.fromJson});

  /// Parameters:
  /// - [tag]: A unique identifier for the storage collection.

  final String tag;

  /// - [id]: The unique identifier of the item to watch.

  final String id;

  /// - [fromJson]: A function to convert JSON data into the model.
  final T Function(Map<String, dynamic>) fromJson;
}

/// Event to watch items in a storage collection that meet a filtering
/// condition.
///
/// This event listens for changes to items that satisfy the given [filter].
///
/// [T] represents a model type that extends [StorableModel].
///

class WatchFilteredItems<T extends StorableModel> extends StorageEvent {
  /// Constructs a [WatchFilteredItems] event.
  WatchFilteredItems({
    required this.tag,
    required this.fromJson,
    required this.filter,
  });

  /// Parameters:
  /// - [tag]: A unique identifier for the storage collection.

  final String tag;

  /// - [fromJson]: A function to convert JSON data into the model.

  final T Function(Map<String, dynamic>) fromJson;

  /// - [filter]: A predicate function to filter the items to watch.
  final bool Function(T item) filter;
}

/// Event to query items from a storage collection that satisfy a filtering
/// condition.
///
/// This event retrieves all items matching the provided [filter]
/// from the collection specified by [tag].
///
/// [T] represents a model type that extends [StorableModel].
///

class QueryItems<T extends StorableModel> extends StorageEvent {
  /// Constructs a [QueryItems] event.
  QueryItems({required this.tag, required this.fromJson, required this.filter});

  /// Parameters:
  /// - [tag]: A unique identifier for the storage collection.

  final String tag;

  /// - [fromJson]: A function to convert JSON data into the model.

  final T Function(Map<String, dynamic>) fromJson;

  /// - [filter]: A predicate function to filter the queried items.
  final bool Function(T item) filter;
}

/// Event to clear all data from a specified storage collection.
///
/// This event deletes all items stored under the provided [tag].

class ClearStorage extends StorageEvent {
  /// Constructs a [ClearStorage] event.
  ClearStorage({required this.tag});

  /// Parameters:
  /// - [tag]: A unique identifier for the storage collection to be cleared.
  final String tag;
}

/// Event to watch raw, unprocessed data from a storage collection.
///
/// This event listens for low-level changes to the storage collection
/// identified by [tag], without transforming the data.
///

class WatchRawData extends StorageEvent {
  /// Constructs a [WatchRawData] event.
  WatchRawData({required this.tag});

  /// Parameters:
  /// - [tag]: A unique identifier for the storage collection.
  final String tag;
}

/// {@template item_updated}
/// Internal event used by the  to notify that an item of type [T]
/// has been updated or loaded from the stream.
///
/// This event is dispatched internally from a stream listener and
/// should not be triggered manually from outside the bloc.
///
/// The [item] can be `null` if the item doesn't exist or was deleted.
/// {@endtemplate}
class ItemUpdated<T> extends StorageEvent {
  /// Creates an [ItemUpdated] event containing the updated or loaded item.
  ItemUpdated(this.item);

  /// The updated or fetched item.
  final T? item;
}

/// {@template storage_errored}
/// Internal event used by the  to propagate stream-related errors
/// in a safe way after the original event handler has completed.
///
/// This avoids calling `emit` from outside the original `on<Event>` callback,
/// which can lead to assertion failures in BLoC.
///
/// The [message] typically describes the error source.
/// {@endtemplate}
class StorageErrored extends StorageEvent {
  /// Creates a [StorageErrored] event with the given error [message].
  StorageErrored(this.message);

  /// Description of the error that occurred.
  final String message;
}
