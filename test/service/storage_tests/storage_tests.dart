// ignore_for_file: discarded_futures

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

@GenerateMocks(<Type>[LocalStorageEngine])
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});
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
      storageBloc = StorageEngineBloc<Comment>(engine: mockEngine);
    });

    tearDown(() async {
      await storageBloc.close();
    });

    test('Initial state should be StorageInitial', () {
      expect(storageBloc.state, isA<StorageInitial>());
    });

    blocTest<StorageEngineBloc<Comment>, StorageState>(
      'LoadItems event should emit [StorageLoading, ItemsLoaded]'
      ' when successful',
      build: () {
        when(
          mockEngine.getAllItems<Comment>(testTag, Comment.fromJson),
        ).thenAnswer((_) async => <Comment>[testComment]);

        return storageBloc;
      },
      act:
          (final StorageEngineBloc<StorableModel> bloc) => bloc.add(
            LoadItems<Comment>(tag: testTag, fromJson: Comment.fromJson),
          ),
      wait: const Duration(milliseconds: 50),
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
          mockEngine.getAllItems<Comment>(any, any),
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
          mockEngine.getItem<Comment>(
            testTag,
            testComment.id,
            Comment.fromJson,
          ),
        ).thenAnswer((_) async => testComment);

        return StorageEngineBloc<Comment>(engine: mockEngine);
      },
      act: (final StorageEngineBloc<Comment> bloc) {
        bloc.add(
          LoadItem<Comment>(
            tag: testTag,
            id: testComment.id,
            fromJson: Comment.fromJson,
          ),
        );
      },
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
          mockEngine.queryItems(testTag, Comment.fromJson, any),
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
          StreamController<List<Comment>>.broadcast();
      when(
        mockEngine.watchItems(testTag, Comment.fromJson),
      ).thenAnswer((_) async => controller.stream);

      final Future<void> expectation = expectLater(
        storageBloc.stream,
        emitsInOrder(<TypeMatcher<ItemsLoaded<Comment>>>[
          isA<ItemsLoaded<Comment>>(),
        ]),
      );

      storageBloc.add(
        WatchItems<Comment>(tag: testTag, fromJson: Comment.fromJson),
      );

      await Future<dynamic>.delayed(const Duration(milliseconds: 20));

      controller.add(testComments);

      await expectation;

      expect(storageBloc.state, isA<ItemsLoaded<Comment>>());
      final ItemsLoaded<Comment> loadedState =
          storageBloc.state as ItemsLoaded<Comment>;
      expect(loadedState.items, equals(testComments));

      await controller.close();
    });

    test('WatchItem emits updates using internal event', () async {
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

      controller.add(testComment);

      await expectLater(
        storageBloc.stream,
        emitsThrough(isA<ItemLoaded<Comment>>()),
      );

      await controller.close();
      await storageBloc.close();
    });

    test('should close all subscriptions when bloc is closed', () async {
      final StreamController<List<Comment>> controller =
          StreamController<List<Comment>>();
      when(
        mockEngine.watchItems(testTag, Comment.fromJson),
      ).thenAnswer((_) async => controller.stream);

      storageBloc.add(
        WatchItems<Comment>(tag: testTag, fromJson: Comment.fromJson),
      );

      await Future<dynamic>.delayed(const Duration(milliseconds: 100));

      await storageBloc.close();

      controller.add(testComments);

      await controller.close();
    });

    test(
      'WatchFilteredItems should emit ItemsLoaded when items are available',
      () async {
        // Create a controller that we can use to simulate stream data
        final StreamController<List<Comment>> controller =
            StreamController<List<Comment>>.broadcast();

        // Mock the storage engine response
        when(
          mockEngine.watchFilteredItems<Comment>(
            testTag,
            Comment.fromJson,
            any,
          ),
        ).thenAnswer((_) async => controller.stream);

        // Create a listener for the bloc's state changes
        final List<StorageState> states = <StorageState>[];
        final StreamSubscription<StorageState> subscription = storageBloc.stream
            .listen(states.add);

        // Add the event to start watching filtered items
        storageBloc.add(
          WatchFilteredItems<Comment>(
            tag: testTag,
            fromJson: Comment.fromJson,
            filter: (final Comment comment) => comment.authorId == 'user1',
          ),
        );

        // Wait for the event to be processed
        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Add data to the stream
        controller.add(<Comment>[testComments[0]]);

        // Wait for the bloc to process the update
        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Verify state changes
        expect(
          states.any(
            (final StorageState state) =>
                state is ItemsLoaded<Comment> &&
                state.items.length == 1 &&
                state.items[0].authorId == 'user1',
          ),
          isTrue,
          reason: 'Should emit ItemsLoaded state with filtered items',
        );

        // Cleanup
        await subscription.cancel();
        await controller.close();
      },
    );

    test(
      'WatchFilteredItems should handle multiple emissions properly',
      () async {
        // Create a controller that we can use to simulate stream data
        final StreamController<List<Comment>> controller =
            StreamController<List<Comment>>.broadcast();

        // Mock the storage engine response
        when(
          mockEngine.watchFilteredItems<Comment>(
            testTag,
            Comment.fromJson,
            any,
          ),
        ).thenAnswer((_) async => controller.stream);

        // Create a listener for the bloc's state changes
        final List<StorageState> states = <StorageState>[];
        final StreamSubscription<StorageState> subscription = storageBloc.stream
            .listen(states.add);

        // Add the event to start watching filtered items
        storageBloc.add(
          WatchFilteredItems<Comment>(
            tag: testTag,
            fromJson: Comment.fromJson,
            filter:
                (final Comment comment) => comment.authorId.startsWith('user'),
          ),
        );

        // Wait for the event to be processed
        await Future<void>.delayed(const Duration(milliseconds: 30));

        // First emission
        controller.add(<Comment>[testComments[0]]);
        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Second emission
        controller.add(<Comment>[testComments[0], testComments[1]]);
        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Verify we received both updates
        final List<ItemsLoaded<Comment>> itemsLoadedStates =
            states.whereType<ItemsLoaded<Comment>>().toList();
        expect(
          itemsLoadedStates.length,
          greaterThanOrEqualTo(2),
          reason: 'Should receive multiple ItemsLoaded states',
        );

        if (itemsLoadedStates.length >= 2) {
          expect(itemsLoadedStates[0].items.length, equals(1));
          expect(itemsLoadedStates[1].items.length, equals(2));
        }

        // Cleanup
        await subscription.cancel();
        await controller.close();
      },
    );

    test('WatchFilteredItems should cancel previous subscription when called '
        'again', () async {
      // Create two controllers for two different subscriptions
      final StreamController<List<Comment>> controller1 =
          StreamController<List<Comment>>.broadcast();
      final StreamController<List<Comment>> controller2 =
          StreamController<List<Comment>>.broadcast();

      // First call returns controller1's stream
      when(
        mockEngine.watchFilteredItems<Comment>(testTag, Comment.fromJson, any),
      ).thenAnswer((_) async => controller1.stream);

      // Add the event to start the first subscription
      storageBloc.add(
        WatchFilteredItems<Comment>(
          tag: testTag,
          fromJson: Comment.fromJson,
          filter: (final Comment comment) => comment.authorId == 'user1',
        ),
      );

      // Wait for processing
      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Now change the mock to return controller2's stream
      when(
        mockEngine.watchFilteredItems<Comment>(testTag, Comment.fromJson, any),
      ).thenAnswer((_) async => controller2.stream);

      // Create a listener for the bloc's state changes
      final List<StorageState> states = <StorageState>[];
      final StreamSubscription<StorageState> subscription = storageBloc.stream
          .listen(states.add);

      // Add the event again with a different filter
      storageBloc.add(
        WatchFilteredItems<Comment>(
          tag: testTag,
          fromJson: Comment.fromJson,
          filter: (final Comment comment) => comment.authorId == 'user2',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Add data to both controllers
      controller1.add(<Comment>[testComments[0]]);
      controller2.add(<Comment>[testComments[1]]);

      await Future<void>.delayed(const Duration(milliseconds: 30));

      // We should only get updates from controller2
      final List<ItemsLoaded<Comment>> itemsLoadedStates =
          states.whereType<ItemsLoaded<Comment>>().toList();
      expect(itemsLoadedStates.isNotEmpty, isTrue);

      if (itemsLoadedStates.isNotEmpty) {
        // Should only have received the update from controller2
        expect(itemsLoadedStates.last.items.length, equals(1));
        expect(itemsLoadedStates.last.items[0].authorId, equals('user2'));
      }

      // Cleanup
      await subscription.cancel();
      await controller1.close();
      await controller2.close();
    });

    test(
      'WatchFilteredItems should stop emitting after bloc is closed',
      () async {
        // Create a controller for the stream
        final StreamController<List<Comment>> controller =
            StreamController<List<Comment>>.broadcast();

        // Mock the storage engine
        when(
          mockEngine.watchFilteredItems<Comment>(
            testTag,
            Comment.fromJson,
            any,
          ),
        ).thenAnswer((_) async => controller.stream);

        // Create a local bloc that we'll close during the test
        final StorageEngineBloc<Comment> localBloc = StorageEngineBloc<Comment>(
            engine: mockEngine,
          )
          // Add the watch event
          ..add(
            WatchFilteredItems<Comment>(
              tag: testTag,
              fromJson: Comment.fromJson,
              filter: (final Comment comment) => true,
            ),
          );

        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Store states before closing
        final List<StorageState> statesBefore = <StorageState>[];
        final StreamSubscription<StorageState> subscription = localBloc.stream
            .listen(statesBefore.add);

        // Send an update
        controller.add(<Comment>[testComments[0]]);
        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Close the bloc
        await subscription.cancel();
        await localBloc.close();

        // Send another update after closing
        controller.add(<Comment>[testComments[1]]);

        // We should have received at least one state before closing
        expect(statesBefore.isNotEmpty, isTrue);
        expect(
          statesBefore.any(
            (final StorageState state) => state is ItemsLoaded<Comment>,
          ),
          isTrue,
        );

        // Cleanup
        await controller.close();
      },
    );

    test(
      'Multiple concurrent save operations should complete successfully',
      () async {
        final List<Comment> batch1 = <Comment>[
          Comment(content: 'Batch 1 - Comment 1', authorId: 'user1'),
          Comment(content: 'Batch 1 - Comment 2', authorId: 'user2'),
        ];

        final List<Comment> batch2 = <Comment>[
          Comment(content: 'Batch 2 - Comment 1', authorId: 'user3'),
          Comment(content: 'Batch 2 - Comment 2', authorId: 'user4'),
        ];

        when(
          unawaited(mockEngine.setItems(testTag, batch1)),
        ).thenAnswer((_) async => <String, dynamic>{});

        when(
          unawaited(mockEngine.setItems(testTag, batch2)),
        ).thenAnswer((_) async => <String, dynamic>{});

        // Collect emitted states
        final List<StorageState> states = <StorageState>[];
        final StreamSubscription<StorageState> subscription = storageBloc.stream
            .listen(states.add);

        // Fire both events in quick succession
        storageBloc
          ..add(SaveItems<Comment>(tag: testTag, items: batch1))
          ..add(SaveItems<Comment>(tag: testTag, items: batch2));

        // Wait for both operations to complete
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Verify both operations completed successfully
        expect(
          states.whereType<StorageActionCompleted>().length,
          equals(2),
          reason: 'Both save operations should complete with success states',
        );

        await subscription.cancel();
      },
    );

    test(
      'Should handle rapid sequential LoadItems operations correctly',
      () async {
        final List<Comment> batch1 = <Comment>[
          Comment(content: 'First batch', authorId: 'user1'),
        ];
        final List<Comment> batch2 = <Comment>[
          Comment(content: 'Second batch', authorId: 'user2'),
        ];

        // Set up mock responses for different tags
        when(
          mockEngine.getAllItems<Comment>('tag1', Comment.fromJson),
        ).thenAnswer((_) async => batch1);

        when(
          mockEngine.getAllItems<Comment>('tag2', Comment.fromJson),
        ).thenAnswer((_) async => batch2);

        final List<StorageState> states = <StorageState>[];
        final StreamSubscription<StorageState> subscription = storageBloc.stream
            .listen(states.add);

        // Fire successive load events with different tags
        storageBloc
          ..add(LoadItems<Comment>(tag: 'tag1', fromJson: Comment.fromJson))
          ..add(LoadItems<Comment>(tag: 'tag2', fromJson: Comment.fromJson));

        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Verify states
        final List<StorageState> loadingStates =
            states.whereType<StorageLoading>().toList();
        final List<ItemsLoaded<Comment>> loadedStates =
            states.whereType<ItemsLoaded<Comment>>().toList();

        expect(
          loadingStates.length,
          equals(2),
          reason: 'Should emit two loading states',
        );
        expect(
          loadedStates.length,
          equals(2),
          reason: 'Should emit two loaded states',
        );

        if (loadedStates.length >= 2) {
          // The last loaded state should match the last request
          expect(loadedStates.last.items[0].authorId, equals('user2'));
        }

        await subscription.cancel();
      },
    );

    test(
      'Error in one subscription should not affect other subscriptions',
      () async {
        final StreamController<List<Comment>> controller1 =
            StreamController<List<Comment>>.broadcast();
        final StreamController<List<Comment>> controller2 =
            StreamController<List<Comment>>.broadcast();

        // First stream will return normal data
        when(
          mockEngine.watchItems<Comment>('tag1', Comment.fromJson),
        ).thenAnswer((_) async => controller1.stream);

        // Second stream will encounter an error
        when(
          mockEngine.watchItems<Comment>('tag2', Comment.fromJson),
        ).thenAnswer((_) async => controller2.stream);

        final List<StorageState> states = <StorageState>[];
        final StreamSubscription<StorageState> subscription = storageBloc.stream
            .listen(states.add);

        // Start watching both streams
        storageBloc
          ..add(WatchItems<Comment>(tag: 'tag1', fromJson: Comment.fromJson))
          ..add(WatchItems<Comment>(tag: 'tag2', fromJson: Comment.fromJson));

        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Add data to first stream
        controller1.add(<Comment>[testComments[0]]);

        // Add error to second stream
        controller2.addError(Exception('Test error in stream'));

        // Add more data to first stream
        await Future<void>.delayed(const Duration(milliseconds: 30));
        controller1.add(<Comment>[testComments[0], testComments[1]]);

        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Verify we got both successful data and errors
        expect(
          states.any(
            (final StorageState s) =>
                s is ItemsLoaded<Comment> && s.items.length == 1,
          ),
          isTrue,
          reason: 'Should receive initial data from first stream',
        );

        expect(
          states.any(
            (final StorageState s) =>
                s is StorageError && s.message.contains('Failed to load items'),
          ),
          isTrue,
          reason: 'Should receive error from second stream',
        );

        expect(
          states.any(
            (final StorageState s) =>
                s is ItemsLoaded<Comment> && s.items.length == 2,
          ),
          isTrue,
          reason: 'Should receive second update from first stream',
        );

        await subscription.cancel();
        await controller1.close();
        await controller2.close();
      },
    );

    test('WatchItem should handle null items properly', () async {
      final StreamController<Comment?> controller =
          StreamController<Comment?>.broadcast();

      when(
        mockEngine.watchItem<Comment>(testTag, 'missing-id', Comment.fromJson),
      ).thenAnswer((_) async => controller.stream);

      final List<StorageState> states = <StorageState>[];
      final StreamSubscription<StorageState> subscription = storageBloc.stream
          .listen(states.add);

      storageBloc.add(
        WatchItem<Comment>(
          tag: testTag,
          id: 'missing-id',
          fromJson: Comment.fromJson,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Send null to simulate item not found
      controller.add(null);

      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Verify state handling
      expect(
        states.any(
          (final StorageState s) => s is ItemLoaded<Comment> && s.item == null,
        ),
        isTrue,
        reason: 'Should emit ItemLoaded with null when item not found',
      );

      await subscription.cancel();
      await controller.close();
    });

    test(
      'SetRawData and GetRawData should handle complex nested objects',
      () async {
        final Map<String, Map<String, Object>> complexData =
            <String, Map<String, Object>>{
              'metadata': <String, Object>{
                'version': 1.5,
                'lastUpdated': DateTime.now().toIso8601String(),
                'flags': <bool>[true, false, true],
              },
              'stats': <String, Object>{
                'counts': <String, int>{'items': 42, 'categories': 7},
                'enabled': true,
              },
            };

        // Mock the setRawData and getRawData methods
        when(
          unawaited(mockEngine.setRawData(testTag, complexData)),
        ).thenAnswer((_) async => <String, dynamic>{});

        when(
          unawaited(mockEngine.getRawData(testTag)),
        ).thenAnswer((_) async => complexData);

        // First save the data
        storageBloc.add(SetRawData(tag: testTag, data: complexData));

        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Create listener for get operation
        final List<StorageState> states = <StorageState>[];
        final StreamSubscription<StorageState> subscription = storageBloc.stream
            .listen(states.add);

        // Then retrieve it
        storageBloc.add(GetRawData(tag: testTag));

        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Verify the retrieved data matches what we stored
        final List<RawDataLoaded> rawDataStates =
            states.whereType<RawDataLoaded>().toList();
        expect(rawDataStates.isNotEmpty, isTrue);

        if (rawDataStates.isNotEmpty) {
          final Map<String, dynamic> retrievedData =
              rawDataStates.last.data as Map<String, dynamic>;
          expect(retrievedData['metadata']['version'], equals(1.5));
          expect(retrievedData['stats']['counts']['items'], equals(42));
          expect(retrievedData['stats']['enabled'], isTrue);
        }

        await subscription.cancel();
      },
    );

    test('Should handle delayed engine responses gracefully', () async {
      // Create a completer to control when the engine responds
      final Completer<List<Comment>> completer = Completer<List<Comment>>();

      when(
        mockEngine.getAllItems<Comment>(testTag, Comment.fromJson),
      ).thenAnswer((_) => completer.future);

      final List<StorageState> states = <StorageState>[];
      final StreamSubscription<StorageState> subscription = storageBloc.stream
          .listen(states.add);

      // Fire the load event
      storageBloc.add(
        LoadItems<Comment>(tag: testTag, fromJson: Comment.fromJson),
      );

      // Verify we're in loading state
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(states.last, isA<StorageLoading>());

      // Complete the future after a delay
      await Future<void>.delayed(const Duration(milliseconds: 100));
      completer.complete(<Comment>[testComments[0]]);

      // Wait for the bloc to process the completed future
      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Verify we moved from loading to loaded state
      expect(states.length, equals(2));
      expect(states.first, isA<StorageLoading>());
      expect(states.last, isA<ItemsLoaded<Comment>>());

      await subscription.cancel();
    });

    test('WatchRawData should properly handle stream errors', () async {
      final StreamController<Map<String, dynamic>> controller =
          StreamController<Map<String, dynamic>>.broadcast();

      when(
        mockEngine.watchRawData(testTag),
      ).thenAnswer((_) async => controller.stream);

      // Add the watch event
      storageBloc.add(WatchRawData(tag: testTag));

      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Listen for states
      final List<StorageState> states = <StorageState>[];
      final StreamSubscription<StorageState> subscription = storageBloc.stream
          .listen(states.add);

      // First send good data
      controller.add(<String, String>{'status': 'ok'});

      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Then send an error
      controller.addError(Exception('Raw data error'));

      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Then send good data again
      controller.add(<String, String>{'status': 'recovered'});

      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Verify error handling
      expect(
        states.any(
          (final StorageState s) =>
              s is RawDataLoaded &&
              (s.data as Map<String, dynamic>)['status'] == 'ok',
        ),
        isTrue,
        reason: 'Should receive initial data',
      );

      expect(
        states.any((final StorageState s) => s is StorageError),
        isTrue,
        reason: 'Should receive error state',
      );

      expect(
        states.any(
          (final StorageState s) =>
              s is RawDataLoaded &&
              (s.data as Map<String, dynamic>)['status'] == 'recovered',
        ),
        isTrue,
        reason: 'Should receive data after error',
      );

      await subscription.cancel();
      await controller.close();
    });

    test('DeleteWhere should handle empty result sets', () async {
      // Mock the removeWhere to simulate no items matching the condition
      when(
        unawaited(mockEngine.removeWhere(testTag, Comment.fromJson, any)),
      ).thenAnswer((_) async => <String, int>{'deletedCount': 0});

      final List<StorageState> states = <StorageState>[];
      final StreamSubscription<StorageState> subscription = storageBloc.stream
          .listen(states.add);

      storageBloc.add(
        DeleteWhere<Comment>(
          tag: testTag,
          fromJson: Comment.fromJson,
          condition: (final Comment comment) => false, // No items will match
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Verify operation completed successfully even with zero deletions
      expect(states.length, equals(1));
      expect(states.first, isA<StorageActionCompleted>());

      await subscription.cancel();
    });

    test(
      'Should maintain consistent state when multiple errors occur',
      () async {
        // Force multiple operations to fail
        when(
          mockEngine.getAllItems<Comment>(any, any),
        ).thenThrow(Exception('Load error'));

        when(
          unawaited(mockEngine.setItem(any, any)),
        ).thenThrow(Exception('Save error'));

        final List<StorageState> states = <StorageState>[];
        final StreamSubscription<StorageState> subscription = storageBloc.stream
            .listen(states.add);

        // Fire multiple operations that will fail
        storageBloc
          ..add(LoadItems<Comment>(tag: testTag, fromJson: Comment.fromJson))
          ..add(SaveItem<Comment>(tag: testTag, item: testComments[0]))
          ..add(
            LoadItems<Comment>(tag: 'another-tag', fromJson: Comment.fromJson),
          );

        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Verify error states
        final List<StorageError> errorStates =
            states.whereType<StorageError>().toList();
        expect(
          errorStates.length,
          equals(3),
          reason: 'Should emit error state for each failed operation',
        );

        expect(errorStates[0].message.contains('Failed to load items'), isTrue);
        expect(errorStates[1].message.contains('Failed to save item'), isTrue);
        expect(errorStates[2].message.contains('Failed to load items'), isTrue);

        await subscription.cancel();
      },
    );


  });
}
