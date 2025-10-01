import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base interface for all storable models.
///
/// This interface ensures that any model implementing it can:
/// - Provide a unique identifier.
/// - Be serialized to JSON format.
/// - Create a copy of itself with updated fields.
abstract class StorableModel {
  /// Unique identifier for the storable model.
  ///
  /// This value must be unique across instances and is typically used
  /// for database keys or in-memory identification.
  String get id;

  /// Converts the model to a JSON-compatible `Map`.
  ///
  /// This method allows the model to be serialized for storage or
  /// network communication. Implementations should return a map
  /// representation of the model's fields.
  Map<String, dynamic> toJson();

  /// Creates a new instance of the model with updated fields.
  ///
  /// This method should return a copy of the current object with
  /// the ability to override specific fields.
  ///
  /// Example:
  /// ```dart
  /// final updatedModel = model.copyWith(name: "New Name");
  /// ```
  StorableModel copyWith();
}

/// Storage engine that handles persistence
class LocalStorageEngine {
  /// Storage engine that handles persistence
  factory LocalStorageEngine() => _instance;

  /// Private named constructor to create an internal instance.
  LocalStorageEngine._internal();

  /// Singleton instance of [LocalStorageEngine].
  static final LocalStorageEngine _instance = LocalStorageEngine._internal();

  /// In-memory cache to store namespaced data.
  ///
  /// Structure:
  /// - Key: Namespace (String).
  /// - Value: Map of data with key-value pairs.
  final Map<String, Map<String, dynamic>> _cache =
      <String, Map<String, dynamic>>{};

  /// Map of stream controllers for broadcasting data updates.
  ///
  /// Structure:
  /// - Key: Namespace (String).
  /// - Value: StreamController emitting data changes.
  final Map<String, StreamController<Map<String, dynamic>>> _controllers =
      <String, StreamController<Map<String, dynamic>>>{};

  /// Get shared preferences instance
  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  /// Initializes and retrieves a [StreamController] for a given collection.
  ///
  /// This method checks if a [StreamController] already exists for the provided
  /// [tag]. If it does not exist, a new broadcast [StreamController] is created
  /// and stored in the internal map. The existing or newly created controller
  /// is then returned.
  ///
  /// Parameters:
  /// - [tag]: A unique identifier for the collection of data to be streamed.
  ///
  /// Returns:
  /// - A [StreamController] instance associated with the given [tag].
  ///
  /// Usage:
  /// This method allows multiple listeners to subscribe to the same stream
  /// through a broadcast controller, enabling real-time updates.
  StreamController<Map<String, dynamic>> _getController(final String tag) {
    if (!_controllers.containsKey(tag)) {
      _controllers[tag] = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _controllers[tag]!;
  }

  /// Loads and returns data associated with a specific [tag].
  ///
  /// This method first checks if the requested [tag] exists in the in-memory
  /// cache. If present, it returns a copy of the cached data. Otherwise, it
  /// retrieves the data from shared preferences, decodes it from JSON format,
  /// and caches it locally for future use.
  ///
  /// If the data is not found or an error occurs during deserialization,
  /// an empty map is returned, and the cache is updated accordingly.
  ///
  /// Parameters:
  /// - [tag]: A unique identifier for the data to be loaded.
  ///
  /// Returns:
  /// - A [Future] that resolves to a [Map<String, dynamic>] containing the
  ///   stored data for the given [tag].
  ///
  /// Exceptions:
  /// - Logs an error message if JSON decoding fails and returns an empty map.
  ///
  /// Usage:
  /// Use this method to load data efficiently with caching to reduce
  /// repeated reads from shared preferences.
  Future<Map<String, dynamic>> _loadData(final String tag) async {
    if (_cache.containsKey(tag)) {
      return Map<String, dynamic>.from(_cache[tag]!);
    }

    final SharedPreferences prefs = await _prefs;
    final String? jsonString = prefs.getString(tag);

    if (jsonString == null) {
      _cache[tag] = <String, dynamic>{};
      return <String, dynamic>{};
    }

    try {
      final Map<String, dynamic> data =
          jsonDecode(jsonString) as Map<String, dynamic>;
      _cache[tag] = data;
      return Map<String, dynamic>.from(data);
    } catch (e) {
      debugPrint('Error loading data for tag $tag: $e');
      _cache[tag] = <String, dynamic>{};
      return <String, dynamic>{};
    }
  }

  /// Saves data associated with a specific [tag].
  ///
  /// This method serializes the provided [data] to a JSON string and stores it
  /// in shared preferences. It also updates the in-memory cache and notifies
  /// listeners through the corresponding stream controller.
  ///
  /// Parameters:
  /// - [tag]: A unique identifier for the data to be saved.
  /// - [data]: A [Map<String, dynamic>] representing the data to be stored.
  ///
  /// Returns:
  /// - A [Future] that completes once the data is saved.
  ///
  /// Usage:
  /// Use this method to persist data and ensure real-time updates via streams.
  Future<void> _saveData(
    final String tag,
    final Map<String, dynamic> data,
  ) async {
    final SharedPreferences prefs = await _prefs;
    final String jsonString = jsonEncode(data);
    await prefs.setString(tag, jsonString);
    _cache[tag] = Map<String, dynamic>.from(data);

    /// Notify listeners
    _getController(tag).add(Map<String, dynamic>.from(data));
  }

  /// Creates or updates an item in a specified collection.
  ///
  /// This method retrieves the current data for the given [tag],
  /// updates the item if it exists, or adds a new one if it doesn't.
  /// The updated data is then saved to persistent storage.
  ///
  /// Parameters:
  /// - [tag]: A unique identifier for the collection where the item is stored.
  /// - [item]: An object of type [T] that extends [StorableModel], representing
  ///   the item to be created or updated.
  ///
  /// Returns:
  /// - A [Future] that completes when the item is successfully stored.
  Future<void> setItem<T extends StorableModel>(
    final String tag,
    final T item,
  ) async {
    final Map<String, dynamic> data = await _loadData(tag);
    data[item.id] = item.toJson();
    await _saveData(tag, data);
  }

  /// Creates or updates multiple items in a specified collection.
  ///
  /// This method retrieves the current data for the given [tag],
  /// updates existing items, or adds new ones from the provided [items] list.
  /// The updated data is then saved to persistent storage.
  ///
  /// Parameters:
  /// - [tag]: A unique identifier for the collection where the items are
  ///   stored.
  /// - [items]: A list of objects of type [T] that extends [StorableModel],
  ///   representing the items to be created or updated.
  ///
  /// Returns:
  /// - A [Future] that completes when all items are successfully stored.
  Future<void> setItems<T extends StorableModel>(
    final String tag,
    final List<T> items,
  ) async {
    final Map<String, dynamic> data = await _loadData(tag);
    for (final T item in items) {
      data[item.id] = item.toJson();
    }
    await _saveData(tag, data);
  }

  /// Retrieves a stored item by its [id] from a specific [tag].
  ///
  /// This method fetches data for the given [tag] from local storage. If the
  /// specified [id] exists, it deserializes the item using the [fromJson]
  /// function
  /// and returns it.
  ///
  /// Parameters:
  /// - [tag]: A unique identifier for the data collection.
  /// - [id]: The unique identifier of the item to retrieve.
  /// - [fromJson]: A function that converts a [Map<String, dynamic>] into
  /// an instance of [T].
  ///
  /// Returns:
  /// - A [Future] that resolves to the item of type [T] if found, otherwise
  /// `null`.
  ///
  /// Usage:
  /// Use this method to retrieve an item from local storage by its identifier.
  Future<T?> getItem<T extends StorableModel>(
    final String tag,
    final String id,
    final T Function(Map<String, dynamic>) fromJson,
  ) async {
    final Map<String, dynamic> data = await _loadData(tag);
    final dynamic itemData = data[id];

    if (itemData == null) {
      return null;
    }

    return fromJson(itemData as Map<String, dynamic>);
  }

  /// Retrieves all stored items from a specific [tag].
  ///
  /// This method loads all the data associated with the given [tag] and
  /// deserializes each item using the [fromJson] function.
  ///
  /// Parameters:
  /// - [tag]: A unique identifier for the data collection.
  /// - [fromJson]: A function that converts a [Map<String, dynamic>] into
  ///   an instance of [T].
  ///
  /// Returns:
  /// - A [Future] that resolves to a list of items of type [T].
  ///
  /// Usage:
  /// Use this method to retrieve all stored items for a particular collection.
  Future<List<T>> getAllItems<T extends StorableModel>(
    final String tag,
    final T Function(Map<String, dynamic>) fromJson,
  ) async {
    final Map<String, dynamic> data = await _loadData(tag);
    return data.values
        .map((final dynamic item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Queries and retrieves items that match a specified [filter] condition.
  ///
  /// This method loads all items under the given [tag], applies the [filter]
  /// function to each item, and returns a list of matching items.
  ///
  /// Parameters:
  /// - [tag]: A unique identifier for the data collection.
  /// - [fromJson]: A function that converts a [Map<String, dynamic>] into an
  /// instance of [T].
  /// - [filter]: A predicate function to filter items of type [T].
  ///
  /// Returns:
  /// - A [Future] that resolves to a list of items of type [T] matching the
  /// filter condition.
  ///
  /// Usage:
  /// Use this method to retrieve items that satisfy a given filter condition.
  Future<List<T>> queryItems<T extends StorableModel>(
    final String tag,
    final T Function(Map<String, dynamic>) fromJson,
    final bool Function(T item) filter,
  ) async {
    final Map<String, dynamic> data = await _loadData(tag);
    final List<T> items =
        data.values
            .map((final dynamic item) => fromJson(item as Map<String, dynamic>))
            .where(filter)
            .toList();
    return items;
  }

  /// Deletes a single item from the data store associated with a specific tag.
  ///
  /// This method retrieves the data corresponding to the provided [tag],
  /// removes the entry identified by the given [id], and then saves the
  /// updated data back to the storage.
  ///
  /// **Parameters:**
  /// - [tag]: A `String` representing the category or group of data to target.
  /// - [id]: A `String` representing the unique identifier of the item to be
  ///   deleted.
  ///
  /// **Returns:**
  /// - A `Future<void>` indicating the completion of the delete operation.
  ///
  /// **Throws:**
  /// - Any errors encountered during data loading or saving will propagate.
  Future<void> removeItem(final String tag, final String id) async {
    final Map<String, dynamic> data = await _loadData(tag);
    data.remove(id);
    await _saveData(tag, data);
  }

  /// Deletes multiple items from the data store associated with a specific tag.
  ///
  /// This method retrieves the data corresponding to the provided [tag],
  /// iterates over the list of [ids] to remove each matching entry, and
  /// then saves the updated data back to the storage.
  ///
  /// **Parameters:**
  /// - [tag]: A `String` representing the category or group of data to target.
  /// - [ids]: A `List<String>` containing unique identifiers of the items
  ///   to be deleted.
  ///
  /// **Returns:**
  /// - A `Future<void>` indicating the completion of the delete operation.
  ///
  /// **Throws:**
  /// - Any errors encountered during data loading or saving will propagate.
  Future<void> removeItems(final String tag, final List<String> ids) async {
    final Map<String, dynamic> data = await _loadData(tag);
    for (int i = 0; i < ids.length; i++) {
      final String id = ids[i];
      data.remove(id);
    }
    await _saveData(tag, data);
  }

  /// Deletes items from the data store associated with a specific tag
  /// if they match a given condition.
  ///
  /// This method retrieves the data corresponding to the provided [tag],
  /// converts each entry to an object of type [T] using the [fromJson]
  /// function,
  /// applies the [condition] to each object, and removes entries that satisfy
  /// the condition. The updated data is then saved back to the storage.
  ///
  /// **Type Parameters:**
  /// - [T]: A type extending `StorableModel` that represents the model of
  /// the data.
  ///
  /// **Parameters:**
  /// - [tag]: A `String` representing the category or group of data to target.
  /// - [fromJson]: A function that converts a `Map<String, dynamic>` to
  /// an object of type [T].
  /// - [condition]: A predicate function that takes an item of type [T]
  /// and returns a `bool`.
  ///   Items for which this function returns `true` will be deleted.
  ///
  /// **Returns:**
  /// - A `Future<void>` indicating the completion of the delete operation.
  ///
  /// **Throws:**
  /// - Any errors encountered during data loading or saving will propagate.
  Future<void> removeWhere<T extends StorableModel>(
    final String tag,
    final T Function(Map<String, dynamic>) fromJson,
    final bool Function(T item) condition,
  ) async {
    final Map<String, dynamic> data = await _loadData(tag);
    final List<String> idsToRemove = <String>[];

    data.forEach((final String id, final dynamic value) {
      final T item = fromJson(value as Map<String, dynamic>);
      if (condition(item)) {
        idsToRemove.add(id);
      }
    });

    for (int i = 0; i < idsToRemove.length; i++) {
      final String id = idsToRemove[i];
      data.remove(id);
    }

    await _saveData(tag, data);
  }

  /// Watches for changes in the data store associated with a specific tag
  /// and provides a stream of items of type [T].
  ///
  /// This method loads the initial data corresponding to the provided [tag],
  /// adds it to the stream controller, and returns a `Stream` that emits
  /// a list of objects of type [T] whenever data changes. The transformation
  /// is done by converting each entry from a `Map<String, dynamic>` using the
  /// provided [fromJson] function.
  ///
  /// **Type Parameters:**
  /// - [T]: A type extending `StorableModel` that represents the model of the
  /// data.
  ///
  /// **Parameters:**
  /// - [tag]: A `String` representing the category or group of data to monitor.
  /// - [fromJson]: A function that converts a `Map<String, dynamic>` to an
  /// object of type [T].
  ///
  /// **Returns:**
  /// - A `Future<Stream<List<T>>>` that emits updated lists of items of
  /// type [T].
  ///
  /// **Throws:**
  /// - Any errors encountered during the initial data load will propagate.
  Future<Stream<List<T>>> watchItems<T extends StorableModel>(
    final String tag,
    final T Function(Map<String, dynamic>) fromJson,
  ) async {
    // Initial load
    await _loadData(tag).then((final Map<String, dynamic> data) {
      _getController(tag).add(data);
    });

    return _getController(tag).stream.map(
      (final Map<String, dynamic> data) =>
          data.values
              .map(
                (final dynamic item) => fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  /// Watches for changes to a specific item in the data store.
  ///
  /// This method loads the initial data for the provided [tag], adds it to the
  /// stream controller, and returns a `Stream` that emits an object of type [T]
  /// whenever the specified item changes. If the item does not exist, `null`
  /// is emitted.
  /// The transformation is performed using the provided [fromJson] function.
  ///
  /// **Type Parameters:**
  /// - [T]: A type extending `StorableModel` that represents the model of the
  /// data.
  ///
  /// **Parameters:**
  /// - [tag]: A `String` representing the category or group of data to monitor.
  /// - [id]: A `String` representing the unique identifier of the item to
  /// watch.
  /// - [fromJson]: A function that converts a `Map<String, dynamic>` to an
  /// object of type [T].
  ///
  /// **Returns:**
  /// - A `Future<Stream<T?>>` that emits the updated item of type [T] or `
  /// null` if not found.
  ///
  /// **Throws:**
  /// - Any errors encountered during the initial data load will propagate.
  Future<Stream<T?>> watchItem<T extends StorableModel>(
    final String tag,
    final String id,
    final T Function(Map<String, dynamic>) fromJson,
  ) async {
    // Initial load
    await _loadData(tag).then((final Map<String, dynamic> data) {
      _getController(tag).add(data);
    });

    return _getController(tag).stream.map((final Map<String, dynamic> data) {
      final dynamic itemData = data[id];
      if (itemData == null) {
        return null;
      }
      return fromJson(itemData as Map<String, dynamic>);
    });
  }

  /// Watches for changes to filtered items in the data store.
  ///
  /// This method loads the initial data for the provided [tag], adds it to the
  /// stream controller, and returns a `Stream` that emits a list of objects of
  /// type [T] whenever data changes. Items are filtered using the provided
  /// [filter]
  /// function, and only matching items are included in the emitted list. The
  /// transformation of data is handled using the [fromJson] function.
  ///
  /// **Type Parameters:**
  /// - [T]: A type extending `StorableModel` that represents the model of
  /// the data.
  ///
  /// **Parameters:**
  /// - [tag]: A `String` representing the category or group of data to monitor.
  /// - [fromJson]: A function that converts a `Map<String, dynamic>` to an
  /// object of type [T].
  /// - [filter]: A predicate function that takes an item of type [T] and
  /// returns a `bool`.
  ///   Items for which this function returns `true` are included in the stream.
  ///
  /// **Returns:**
  /// - A `Future<Stream<List<T>>>` that emits filtered lists of items
  /// of type [T].
  ///
  /// **Throws:**
  /// - Any errors encountered during the initial data load will propagate.
  Future<Stream<List<T>>> watchFilteredItems<T extends StorableModel>(
    final String tag,
    final T Function(Map<String, dynamic>) fromJson,
    final bool Function(T item) filter,
  ) async {
    // Initial load
    await _loadData(tag).then((final Map<String, dynamic> data) {
      _getController(tag).add(data);
    });

    return _getController(tag).stream.map(
      (final Map<String, dynamic> data) =>
          data.values
              .map(
                (final dynamic item) => fromJson(item as Map<String, dynamic>),
              )
              .where(filter)
              .toList(),
    );
  }

  /// Clears all data associated with the specified tag.
  ///
  /// This method removes the stored data for the provided [tag] from both
  /// persistent storage (using `SharedPreferences`) and the in-memory cache.
  /// It also updates the corresponding stream controller with an empty map,
  /// ensuring any listeners are notified of the cleared state.
  ///
  /// **Parameters:**
  /// - [tag]: A `String` representing the category or group of data to clear.
  ///
  /// **Returns:**
  /// - A `Future<void>` that completes when the data is successfully cleared.
  ///
  /// **Throws:**
  /// - Any errors encountered while accessing or modifying `SharedPreferences`
  /// will propagate.
  Future<void> clearTag(final String tag) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(tag);
    _cache.remove(tag);
    _getController(tag).add(<String, dynamic>{});
  }

  /// Stores raw data for a specified tag.
  ///
  /// This method encodes the provided [data] into a JSON string and stores it
  /// in `SharedPreferences` under a key prefixed with `raw_`. It supports
  /// storing primitive types or custom structures. If a corresponding stream
  /// controller exists, it will notify listeners with the updated data.
  ///
  /// **Parameters:**
  /// - [tag]: A `String` representing the key under which the data is stored.
  /// - [data]: A `dynamic` value representing the raw data to store. This can
  ///   include primitive types (e.g., `int`, `double`, `String`, `bool`) or
  ///   custom structures that are JSON-serializable.
  ///
  /// **Returns:**
  /// - A `Future<void>` that completes when the data is successfully stored.
  ///
  /// **Throws:**
  /// - Any errors encountered while encoding or storing the data will
  /// propagate.
  Future<void> setRawData(final String tag, final dynamic data) async {
    final SharedPreferences prefs = await _prefs;
    final String jsonString = jsonEncode(<String, dynamic>{'data': data});
    await prefs.setString('raw_$tag', jsonString);

    // Notify if any controllers exist
    if (_controllers.containsKey('raw_$tag')) {
      _controllers['raw_$tag']!.add(<String, dynamic>{'data': data});
    }
  }

  /// Retrieves raw data for a specified tag.
  ///
  /// This method fetches and decodes the raw data associated with the given
  /// [tag] from `SharedPreferences`. The data is expected to be stored as a
  /// JSON string. You can optionally specify a [dataTag] to extract a specific
  /// value from the decoded data map.
  ///
  /// **Parameters:**
  /// - [tag]: A `String` representing the key under which the data is stored.
  /// - [dataTag]: (Optional) A `String` representing the key within the JSON
  ///   object to retrieve. Defaults to `'data'`.
  ///
  /// **Returns:**
  /// - A `Future<dynamic>` that resolves to the decoded data if available,
  ///   or `null` if the data is not found or an error occurs during decoding.
  ///
  /// **Throws:**
  /// - Any errors during data retrieval or decoding are caught and logged,
  ///   and `null` is returned instead of propagating the exception.
  Future<dynamic> getRawData(
    final String tag, {
    final String dataTag = 'data',
  }) async {
    final SharedPreferences prefs = await _prefs;
    final String? jsonString = prefs.getString('raw_$tag');

    if (jsonString == null) {
      return null;
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return decoded[dataTag];
    } catch (e) {
      debugPrint('Error loading raw data for tag $tag: $e');
      return null;
    }
  }

  /// Watches raw data for a specified tag.
  ///
  /// This method provides a stream that emits updates to the raw data
  /// associated with the given [tag]. It fetches the initial data from
  /// `SharedPreferences` and listens for further changes via the stream
  /// controller. You can optionally specify a [dataTag] to extract a specific
  /// value from the emitted data.
  ///
  /// **Parameters:**
  /// - [tag]: A `String` representing the key under which the data is stored.
  /// - [dataTag]: (Optional) A `String` representing the key within the JSON
  ///   object to retrieve. Defaults to `'data'`.
  ///
  /// **Returns:**
  /// - A `Future<Stream<dynamic>>` that emits the raw data as it is updated.
  ///
  /// **Throws:**
  /// - Any errors during data retrieval or stream operations are propagated.
  Future<Stream<dynamic>> watchRawData(
    final String tag, {
    final String dataTag = 'data',
  }) async {
    final StreamController<Map<String, dynamic>> controller = _getController(
      'raw_$tag',
    );

    // Initial load
    await getRawData(tag).then((final dynamic data) {
      if (data != null) {
        controller.add(<String, dynamic>{dataTag: data});
      }
    });

    return controller.stream.map(
      (final Map<String, dynamic> data) => data[dataTag],
    );
  }

  /// Disposes all active stream controllers.
  ///
  /// This method iterates through all stored stream controllers, closes
  /// each one asynchronously, and then clears the `_controllers` map.
  ///
  /// It should be called when the instance is no longer needed to
  /// release resources and prevent memory leaks.
  ///
  /// **Returns:**
  /// - A `Future<void>` indicating when all controllers have been closed.
  Future<void> dispose() async {
    for (final StreamController<Map<String, dynamic>> controller
        in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();
  }
}
