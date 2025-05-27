import 'package:collection/collection.dart';
import 'package:test/test.dart';

/// Returns the single unique element when all others appear exactly twice.
/// Uses deep equality for complex types.
/// Throws StateError if no unique element found.
T findSingleUnique<T>(final List<T> list) {
  const DeepCollectionEquality equality = DeepCollectionEquality();
  final List<T> uniqueElements = <T>[];
  final List<int> counts = <int>[];

  for (final T element in list) {
    final int index = uniqueElements.indexWhere(
      (final T e) => equality.equals(e, element),
    );
    if (index == -1) {
      uniqueElements.add(element);
      counts.add(1);
    } else {
      counts[index]++;
    }
  }

  for (int i = 0; i < counts.length; i++) {
    if (counts[i] == 1) {
      return uniqueElements[i];
    }
  }

  throw StateError('No unique element found');
}

void main() {
  group('findSingleUnique', () {
    test('finds unique integer', () {
      final List<int> nums = <int>[2, 3, 5, 4, 5, 3, 4];
      expect(findSingleUnique(nums), 2);
    });

    test('finds unique string', () {
      final List<String> words = <String>['a', 'b', 'a', 'c', 'b'];
      expect(findSingleUnique(words), 'c');
    });

    test('throws when no unique exists', () {
      final List<int> nums = <int>[1, 1, 2, 2];
      expect(() => findSingleUnique(nums), throwsStateError);
    });

    test('works with single-element list', () {
      expect(findSingleUnique(<int>[42]), 42);
    });

    test('works with non-primitive types', () {
      final List<List<int>> nested = <List<int>>[
        <int>[1],
        <int>[2],
        <int>[1],
        <int>[2],
        <int>[3],
      ];
      expect(findSingleUnique(nested), <int>[3]);
    });
  });
}
