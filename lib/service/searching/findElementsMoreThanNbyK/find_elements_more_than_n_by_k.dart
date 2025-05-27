import 'package:test/test.dart';

/// Returns a list of elements that appear more than n/k times in the list.
/// Throws ArgumentError if k <= 0 or list is empty.
List<T> findElementsMoreThanNbyK<T>(final List<T> list, final int k) {
  if (k <= 0) {
    throw ArgumentError('k must be greater than 0');
  }
  if (list.isEmpty) {
    throw ArgumentError('List cannot be empty');
  }

  final Map<T, int> freq = <T, int>{};
  for (final T element in list) {
    freq[element] = (freq[element] ?? 0) + 1;
  }

  final int threshold = list.length ~/ k;
  return freq.entries
      .where((final MapEntry<T, int> entry) => entry.value > threshold)
      .map((final MapEntry<T, int> entry) => entry.key)
      .toList();
}

void main() {
  group('findElementsMoreThanNbyK', () {
    test('finds elements appearing more than n/k times', () {
      final List<int> nums = <int>[3, 1, 2, 2, 1, 2, 3, 3];
      final List<int> result = findElementsMoreThanNbyK(nums, 4);
      expect(result.toSet(), <int>{2, 3});
    });

    test('returns empty list if no elements qualify', () {
      final List<int> nums = <int>[1, 2, 3, 4, 5];
      final List<int> result = findElementsMoreThanNbyK(nums, 2);
      expect(result, isEmpty);
    });

    test('works with strings', () {
      final List<String> words = <String>['a', 'b', 'a', 'c', 'a', 'b', 'a'];
      final List<String> result = findElementsMoreThanNbyK(words, 3);
      expect(result, <String>['a']);
    });

    test('throws on empty list', () {
      expect(() => findElementsMoreThanNbyK(<int>[], 3), throwsArgumentError);
    });

    test('throws when k <= 0', () {
      expect(
        () => findElementsMoreThanNbyK(<int>[1, 2, 3], 0),
        throwsArgumentError,
      );
      expect(() => findElementsMoreThanNbyK(<int>[1], -1), throwsArgumentError);
    });

    test('works with complex types (by reference)', () {
      final List<int> list1 = <int>[1];
      final List<int> list2 = <int>[2];
      final List<int> list3 = <int>[1];
      final List<List<int>> input = <List<int>>[
        list1,
        list2,
        list3,
        list1,
        list1,
      ];
      final List<List<int>> result = findElementsMoreThanNbyK(input, 3);
      expect(result.length, 1);
      expect(result[0], same(list1));
    });
  });
}
