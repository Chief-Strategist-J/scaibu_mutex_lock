import 'package:collection/collection.dart';
import 'package:test/test.dart';

/// Returns the first duplicate element found in the list based on
/// the earliest second occurrence (lowest second index).
/// Uses deep equality for complex objects.
/// Throws ArgumentError if no duplicates found.
T findFirstDuplicateByIndex<T>(final List<T> list) {
  const DeepCollectionEquality equality = DeepCollectionEquality();
  final Map<int, T> duplicateCandidates = <int, T>{};
  final List<T> seen = <T>[];

  // Map from element to first index it appeared
  final Map<T, int> firstIndexes = <T, int>{};

  for (int i = 0; i < list.length; i++) {
    final T element = list[i];

    // Check if element seen before (by deep equality)
    final int seenIndex = seen.indexWhere(
      (final T e) => equality.equals(e, element),
    );
    if (seenIndex == -1) {
      seen.add(element);
      firstIndexes[element] = i;
    } else {
      // Duplicate found; record the second occurrence index as key
      duplicateCandidates[i] = element;
    }
  }

  if (duplicateCandidates.isEmpty) {
    throw ArgumentError('No duplicates found');
  }

  // Find the duplicate with the smallest second occurrence index
  final int minSecondIndex = duplicateCandidates.keys.reduce(
    (final int a, final int b) => a < b ? a : b,
  );
  return duplicateCandidates[minSecondIndex] as T;
}

void main() {
  group('findFirstDuplicateByIndex with deep equality', () {
    test('finds first duplicate by earliest second occurrence index', () {
      final List<int> nums = <int>[3, 1, 2, 3, 2, 1];
      // 3 repeats at index 3 (second occurrence), 2 repeats at 4, 1 repeats
      // at 5
      expect(findFirstDuplicateByIndex(nums), 3);
    });

    test('finds first duplicate with strings', () {
      final List<String> words = <String>[
        'apple',
        'banana',
        'pear',
        'banana',
        'apple',
      ];
      // banana repeats first at index 3, apple repeats later at 4
      expect(findFirstDuplicateByIndex(words), 'banana');
    });

    test('finds first duplicate with complex objects (lists)', () {
      final List<List<int>> lists = <List<int>>[
        <int>[1, 2],
        <int>[3, 4],
        <int>[5, 6],
        <int>[3, 4], // second occurrence index 3
        <int>[1, 2], // second occurrence index 4
      ];
      expect(findFirstDuplicateByIndex(lists), <int>[3, 4]);
    });

    test('throws ArgumentError if no duplicates found', () {
      final List<int> nums = <int>[1, 2, 3, 4, 5];
      expect(() => findFirstDuplicateByIndex(nums), throwsArgumentError);
    });
  });
}
