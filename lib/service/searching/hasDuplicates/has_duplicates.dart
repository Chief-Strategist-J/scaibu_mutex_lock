import 'package:collection/collection.dart';
import 'package:test/test.dart';

/// Generic reusable function to check if a List<T>
/// contains any duplicates.
/// Returns true if duplicates exist, false otherwise.
bool hasDuplicates<T>(final List<T> list) {
  const DeepCollectionEquality equality = DeepCollectionEquality();
  for (int i = 0; i < list.length; i++) {
    for (int j = i + 1; j < list.length; j++) {
      if (equality.equals(list[i], list[j])) {
        return true;
      }
    }
  }
  return false;
}

void main() {
  group('hasDuplicates', () {
    test('returns true when duplicates exist in integers', () {
      final List<int> nums = <int>[1, 2, 3, 2, 5];
      expect(hasDuplicates(nums), isTrue);
    });

    test('returns false when all integers are unique', () {
      final List<int> nums = <int>[1, 2, 3, 4, 5];
      expect(hasDuplicates(nums), isFalse);
    });

    test('returns true when duplicates exist in strings', () {
      final List<String> words = <String>['apple', 'banana', 'apple'];
      expect(hasDuplicates(words), isTrue);
    });

    test('returns false when all strings are unique', () {
      final List<String> words = <String>['apple', 'banana', 'pear'];
      expect(hasDuplicates(words), isFalse);
    });

    test('returns false on empty list', () {
      final List<int> empty = <int>[];
      expect(hasDuplicates(empty), isFalse);
    });

    test('returns true when duplicates exist with complex objects', () {
      final List<List<int>> lists = <List<int>>[
        <int>[1, 2],
        <int>[3, 4],
        <int>[1, 2], // duplicate by reference
      ];
      expect(hasDuplicates(lists), isTrue);
    });

    test('returns false when all complex objects are unique', () {
      final List<List<int>> lists = <List<int>>[
        <int>[1, 2],
        <int>[3, 4],
        <int>[5, 6],
      ];
      expect(hasDuplicates(lists), isFalse);
    });
  });
}
