import 'package:collection/collection.dart';
import 'package:test/test.dart';

/// Returns a List<T> containing all duplicate elements in the input list.
/// Each duplicate element appears only once in the result,
/// even if it occurs multiple times in the input.
/// Uses deep equality for complex objects.
List<T> findAllDuplicates<T>(final List<T> list) {
  const DeepCollectionEquality equality = DeepCollectionEquality();
  final List<T> duplicates = <T>[];
  final List<T> seen = <T>[];

  for (final T element in list) {
    final bool alreadySeen = seen.any(
      (final T e) => equality.equals(e, element),
    );
    if (!alreadySeen) {
      seen.add(element);
    } else {
      final bool alreadyDuplicate = duplicates.any(
        (final T e) => equality.equals(e, element),
      );
      if (!alreadyDuplicate) {
        duplicates.add(element);
      }
    }
  }
  return duplicates;
}

void main() {
  group('findAllDuplicates with deep equality', () {
    test('find duplicates in list of integers', () {
      final List<int> nums = <int>[1, 2, 3, 2, 5, 1, 6];
      expect(findAllDuplicates(nums), unorderedEquals(<int>[1, 2]));
    });

    test('find duplicates in list of strings', () {
      final List<String> words = <String>[
        'apple',
        'banana',
        'apple',
        'pear',
        'banana',
      ];
      expect(
        findAllDuplicates(words),
        unorderedEquals(<String>['apple', 'banana']),
      );
    });

    test('returns empty list when no duplicates', () {
      final List<int> nums = <int>[1, 2, 3, 4, 5];
      expect(findAllDuplicates(nums), isEmpty);
    });

    test('returns empty list on empty input', () {
      final List<int> empty = <int>[];
      expect(findAllDuplicates(empty), isEmpty);
    });

    test('find duplicates in complex objects (lists)', () {
      final List<List<int>> lists = <List<int>>[
        <int>[1, 2],
        <int>[3, 4],
        <int>[1, 2], // duplicate by content
        <int>[5, 6],
        <int>[3, 4], // duplicate by content
      ];
      final List<List<int>> result = findAllDuplicates(lists);
      expect(result.length, 2);
      expect(
        result,
        containsAll(<List<int>>[
          <int>[1, 2],
          <int>[3, 4],
        ]),
      );
    });

    test('duplicates appear only once in result', () {
      final List<int> nums = <int>[1, 1, 1, 2, 2, 3];
      final List<int> duplicates = findAllDuplicates(nums);
      expect(duplicates.length, 2);
      expect(duplicates, containsAll(<dynamic>[1, 2]));
    });
  });
}
