import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:scaibu_mutex_lock/service/storage/storageEngine/storage_engine_bloc.dart';
import 'package:scaibu_mutex_lock/service/storage/storageEngine/storage_engine_event.dart';
import 'package:scaibu_mutex_lock/service/storage/storageEngine/storage_engine_state.dart';
import 'package:scaibu_mutex_lock/service/storage/storage_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/comment.dart';
import 'storage_tests.mocks.dart';

// Creating a mock of LocalStorageEngine for testing
@GenerateMocks(<Type>[LocalStorageEngine])
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(
    <String, Object>{},
  ); // Set empty initial values
  group('StorageEngineBloc Tests', () {
    late StorageEngineBloc<Comment> storageBloc;
    late MockLocalStorageEngine mockEngine;
    const String testTag = 'comments';

    // Sample test data
    final Comment testComment = Comment(
      content: 'This is a test comment',
      authorId: 'user123',
    );

    final List<Comment> testComments = <Comment>[
      Comment(content: 'First comment', authorId: 'user1'),
      Comment(content: 'Second comment', authorId: 'user2'),
    ];

    setUp(() {
      mockEngine = MockLocalStorageEngine();
      storageBloc = StorageEngineBloc<Comment>();
    });

    tearDown(() async {
      await storageBloc.close();
    });

    test('Initial state should be StorageInitial', () {
      expect(storageBloc.state, isA<StorageInitial>());
    });

    blocTest<StorageEngineBloc<Comment>, StorageState>(
      'LoadItems event should emit [StorageLoading, ItemsLoaded] when '
      'successful',
      build: () {
        when(
          unawaited(mockEngine.getAllItems<Comment>(testTag, Comment.fromJson)),
        ).thenAnswer((_) async {
          await Future<dynamic>.delayed(const Duration(milliseconds: 10));
        });
        return storageBloc;
      },
      act:
          (final StorageEngineBloc<StorableModel> bloc) => bloc.add(
            LoadItems<Comment>(tag: testTag, fromJson: Comment.fromJson),
          ),
      wait: const Duration(milliseconds: 50), // Allow time for the state change
      expect:
          () => <TypeMatcher<StorageState>>[
            isA<StorageLoading>(),
            isA<ItemsLoaded<Comment>>(),
          ],
    );

    blocTest<StorageEngineBloc<Comment>, StorageState>(
      'LoadItems event should emit [StorageLoading, StorageError] when'
      ' exception occurs',
      build: () {
        when(
          unawaited(mockEngine.getAllItems<Comment>(any, any)),
        ).thenThrow(Exception('Test error'));
        return storageBloc;
      },
      act:
          (final StorageEngineBloc<StorableModel> bloc) => bloc.add(
            LoadItems<Comment>(tag: testTag, fromJson: Comment.fromJson),
          ),
      expect:
          () => <TypeMatcher<StorageState>>[
            isA<StorageLoading>(),
            isA<StorageError>(),
          ],
      verify: (final StorageEngineBloc<StorableModel> bloc) {
        final StorageError state = bloc.state as StorageError;
        expect(state.message, contains('Failed to load items'));
      },
    );

    blocTest<StorageEngineBloc<Comment>, StorageState>(
      'LoadItem event should emit [StorageLoading, ItemLoaded] when successful',
      build: () {
        when(
          unawaited(
            mockEngine.getItem<Comment>(
              testTag,
              testComment.id,
              Comment.fromJson,
            ),
          ),
        ).thenAnswer((_) async => testComment);

        return storageBloc;
      },
      act:
          (final StorageEngineBloc<Comment> bloc) => bloc.add(
            LoadItem<Comment>(
              tag: testTag,
              id: testComment.id,
              fromJson: Comment.fromJson,
            ),
          ),
      expect:
          () => <TypeMatcher<StorageState>>[
            isA<StorageLoading>(),
            isA<ItemLoaded<Comment>>(),
          ],
      verify: (final StorageEngineBloc<Comment> bloc) {
        final ItemLoaded<Comment> state = bloc.state as ItemLoaded<Comment>;
        expect(state.item, isNotNull);
        expect(state.item!.content, equals('This is a test comment'));
      },
    );

    blocTest<StorageEngineBloc<Comment>, StorageState>(
      'SaveItem event should emit [StorageActionCompleted] when successful',
      build: () {
        when(
          unawaited(mockEngine.setItem(testTag, testComment)),
        ).thenAnswer((_) async => <String, dynamic>{});
        return storageBloc;
      },
      act:
          (final StorageEngineBloc<StorableModel> bloc) =>
              bloc.add(SaveItem<Comment>(tag: testTag, item: testComment)),
      expect:
          () => <TypeMatcher<StorageActionCompleted>>[
            isA<StorageActionCompleted>(),
          ],
      verify: (final StorageEngineBloc<StorableModel> bloc) {
        final StorageActionCompleted state =
            bloc.state as StorageActionCompleted;
        expect(state.message, equals('Item saved successfully'));
      },
    );

    blocTest<StorageEngineBloc<Comment>, StorageState>(
      'SaveItems event should emit [StorageActionCompleted] when successful',
      build: () {
        when(
          unawaited(mockEngine.setItems(testTag, testComments)),
        ).thenAnswer((_) async => <String, dynamic>{});
        return storageBloc;
      },
      act:
          (final StorageEngineBloc<StorableModel> bloc) =>
              bloc.add(SaveItems<Comment>(tag: testTag, items: testComments)),
      expect:
          () => <TypeMatcher<StorageActionCompleted>>[
            isA<StorageActionCompleted>(),
          ],
      verify: (final StorageEngineBloc<StorableModel> bloc) {
        final StorageActionCompleted state =
            bloc.state as StorageActionCompleted;
        expect(state.message, equals('Items saved successfully'));
      },
    );

    blocTest<StorageEngineBloc<Comment>, StorageState>(
      'DeleteItem event should emit [StorageActionCompleted] when successful',
      build: () {
        when(
          unawaited(mockEngine.removeItem(testTag, testComment.id)),
        ).thenAnswer((_) async => <String, dynamic>{});
        return storageBloc;
      },
      act:
          (final StorageEngineBloc<StorableModel> bloc) =>
              bloc.add(DeleteItem(tag: testTag, id: testComment.id)),
      expect:
          () => <TypeMatcher<StorageActionCompleted>>[
            isA<StorageActionCompleted>(),
          ],
      verify: (final StorageEngineBloc<StorableModel> bloc) {
        final StorageActionCompleted state =
            bloc.state as StorageActionCompleted;
        expect(state.message, equals('Item deleted successfully'));
      },
    );

    blocTest<StorageEngineBloc<Comment>, StorageState>(
      'DeleteItems event should emit [StorageActionCompleted] when successful',
      build: () {
        final List<String> ids =
            testComments.map((final Comment c) => c.id).toList();
        when(
          unawaited(mockEngine.removeItems(testTag, ids)),
        ).thenAnswer((_) async => <String, dynamic>{});
        return storageBloc;
      },
      act:
          (final StorageEngineBloc<StorableModel> bloc) => bloc.add(
            DeleteItems(
              tag: testTag,
              ids: testComments.map((final Comment c) => c.id).toList(),
            ),
          ),
      expect:
          () => <TypeMatcher<StorageActionCompleted>>[
            isA<StorageActionCompleted>(),
          ],
      verify: (final StorageEngineBloc<StorableModel> bloc) {
        final StorageActionCompleted state =
            bloc.state as StorageActionCompleted;
        expect(state.message, equals('Items deleted successfully'));
      },
    );

    blocTest<StorageEngineBloc<Comment>, StorageState>(
      'DeleteWhere event should emit [StorageActionCompleted] when successful',
      build: () {
        when(
          unawaited(mockEngine.removeWhere(testTag, Comment.fromJson, any)),
        ).thenAnswer((_) async => <String, dynamic>{});
        return storageBloc;
      },
      act:
          (final StorageEngineBloc<StorableModel> bloc) => bloc.add(
            DeleteWhere<Comment>(
              tag: testTag,
              fromJson: Comment.fromJson,
              condition: (final Comment comment) => comment.authorId == 'user1',
            ),
          ),
      expect:
          () => <TypeMatcher<StorageActionCompleted>>[
            isA<StorageActionCompleted>(),
          ],
      verify: (final StorageEngineBloc<StorableModel> bloc) {
        final StorageActionCompleted state =
            bloc.state as StorageActionCompleted;
        expect(state.message, equals('Items deleted successfully'));
      },
    );

    blocTest<StorageEngineBloc<Comment>, StorageState>(
      'QueryItems event should emit [StorageLoading, ItemsLoaded] '
      'when successful',
      build: () {
        when(
          unawaited(mockEngine.queryItems(testTag, Comment.fromJson, any)),
        ).thenAnswer((_) async => <Comment>[testComments[0]]);
        return storageBloc;
      },
      act:
          (final StorageEngineBloc<StorableModel> bloc) => bloc.add(
            QueryItems<Comment>(
              tag: testTag,
              fromJson: Comment.fromJson,
              filter: (final Comment comment) => comment.authorId == 'user1',
            ),
          ),
      expect:
          () => <TypeMatcher<StorageState>>[
            isA<StorageLoading>(),
            isA<ItemsLoaded<Comment>>(),
          ],
      verify: (final StorageEngineBloc<StorableModel> bloc) {
        final ItemsLoaded<Comment> state = bloc.state as ItemsLoaded<Comment>;
        expect(state.items.length, equals(1));
      },
    );

    blocTest<StorageEngineBloc<Comment>, StorageState>(
      'ClearStorage event should emit [StorageActionCompleted] when successful',
      build: () {
        when(
          unawaited(mockEngine.clearTag(testTag)),
        ).thenAnswer((_) async => <String, dynamic>{});
        return storageBloc;
      },
      act:
          (final StorageEngineBloc<StorableModel> bloc) =>
              bloc.add(ClearStorage(tag: testTag)),
      expect:
          () => <TypeMatcher<StorageActionCompleted>>[
            isA<StorageActionCompleted>(),
          ],
      verify: (final StorageEngineBloc<StorableModel> bloc) {
        final StorageActionCompleted state =
            bloc.state as StorageActionCompleted;
        expect(state.message, equals('Storage cleared successfully'));
      },
    );

    blocTest<StorageEngineBloc<Comment>, StorageState>(
      'SetRawData event should emit [StorageActionCompleted] when successful',
      build: () {
        when(
          unawaited(mockEngine.setRawData(testTag, any)),
        ).thenAnswer((_) async => <String, dynamic>{});
        return storageBloc;
      },
      act:
          (final StorageEngineBloc<StorableModel> bloc) => bloc.add(
            SetRawData(
              tag: testTag,
              data: <String, String>{
                'lastUpdated': DateTime.now().toIso8601String(),
              },
            ),
          ),
      expect:
          () => <TypeMatcher<StorageActionCompleted>>[
            isA<StorageActionCompleted>(),
          ],
      verify: (final StorageEngineBloc<StorableModel> bloc) {
        final StorageActionCompleted state =
            bloc.state as StorageActionCompleted;
        expect(state.message, equals('Raw data saved successfully'));
      },
    );

    blocTest<StorageEngineBloc<Comment>, StorageState>(
      'GetRawData event should emit [StorageLoading, RawDataLoaded] when '
      'successful',
      build: () {
        final Map<String, String> rawData = <String, String>{
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        when(
          unawaited(mockEngine.getRawData(testTag)),
        ).thenAnswer((_) async => rawData);
        return storageBloc;
      },
      act:
          (final StorageEngineBloc<StorableModel> bloc) =>
              bloc.add(GetRawData(tag: testTag)),
      expect:
          () => <TypeMatcher<StorageState>>[
            isA<StorageLoading>(),
            isA<RawDataLoaded>(),
          ],
      verify: (final StorageEngineBloc<Comment> bloc) {
        final RawDataLoaded state = bloc.state as RawDataLoaded;
        expect(state.data, isNotNull);
        expect(state.data, isA<Map<String, dynamic>>());
      },
    );

    test('WatchItems should set up a subscription and emit updates', () async {
      final StreamController<List<Comment>> controller =
          StreamController<List<Comment>>();
      when(
        mockEngine.watchItems(testTag, Comment.fromJson),
      ).thenAnswer((_) async => controller.stream);

      storageBloc.add(
        WatchItems<Comment>(tag: testTag, fromJson: Comment.fromJson),
      );

      // Wait for event to be processed
      await Future<dynamic>.delayed(const Duration(milliseconds: 100));

      // Simulate data update
      controller.add(testComments);

      // Wait for state to be updated
      await Future<dynamic>.delayed(const Duration(milliseconds: 100));

      expect(storageBloc.state, isA<ItemsLoaded<Comment>>());

      // Clean up
      await controller.close();
    });

    test('WatchItem should set up a subscription and emit updates', () async {
      final StreamController<Comment?> controller =
          StreamController<Comment?>();
      when(
        mockEngine.watchItem(testTag, testComment.id, Comment.fromJson),
      ).thenAnswer((_) async => controller.stream);

      storageBloc.add(
        WatchItem<Comment>(
          tag: testTag,
          id: testComment.id,
          fromJson: Comment.fromJson,
        ),
      );

      // Wait for event to be processed
      await Future<dynamic>.delayed(const Duration(milliseconds: 100));

      // Simulate data update
      controller.add(testComment);

      // Wait for state to be updated
      await Future<dynamic>.delayed(const Duration(milliseconds: 100));

      expect(storageBloc.state, isA<ItemLoaded<Comment>>());

      // Clean up
      await controller.close();
    });

    test('should close all subscriptions when bloc is closed', () async {
      // Setup a stream controller and subscription
      final StreamController<List<Comment>> controller =
          StreamController<List<Comment>>();
      when(
        mockEngine.watchItems(testTag, Comment.fromJson),
      ).thenAnswer((_) async => controller.stream);

      storageBloc.add(
        WatchItems<Comment>(tag: testTag, fromJson: Comment.fromJson),
      );

      // Wait for event to be processed
      await Future<dynamic>.delayed(const Duration(milliseconds: 100));

      // Close the bloc
      await storageBloc.close();

      // Verify all subscriptions are closed (should not cause any errors)
      controller.add(testComments); // Should not affect closed bloc

      // Clean up
      await controller.close();
    });
  });
}
