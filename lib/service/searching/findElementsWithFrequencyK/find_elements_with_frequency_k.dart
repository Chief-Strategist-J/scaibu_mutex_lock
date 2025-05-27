import 'package:test/test.dart';

/// Returns a list of elements that appear exactly `k` times in the list.
/// Throws ArgumentError if k <= 0 or list is empty.
List<T> findElementsWithFrequencyK<T>(final List<T> list, final int k) {
  if (k <= 0) {
    throw ArgumentError('k must be greater than 0');
  }
  if (list.isEmpty) {
    throw ArgumentError('List cannot be empty');
  }

  final Map<T, int> frequencyMap = <T, int>{};
  for (final T element in list) {
    frequencyMap[element] = (frequencyMap[element] ?? 0) + 1;
  }

  return frequencyMap.entries
      .where((final MapEntry<T, int> entry) => entry.value == k)
      .map((final MapEntry<T, int> entry) => entry.key)
      .toList();
}

void main() {
  group('findElementsWithFrequencyK', () {
    test('finds elements with frequency exactly 2', () {
      final List<int> nums = <int>[1, 2, 2, 3, 1, 4];
      final List<int> result = findElementsWithFrequencyK(nums, 2);
      expect(result.toSet(), <int>{1, 2});
    });

    test('returns empty list if no element has given frequency', () {
      final List<int> nums = <int>[1, 2, 3];
      final List<int> result = findElementsWithFrequencyK(nums, 2);
      expect(result, isEmpty);
    });

    test('finds string elements with frequency exactly 3', () {
      final List<String> words = <String>[
        'apple',
        'banana',
        'apple',
        'banana',
        'banana',
        'apple',
      ];
      final List<String> result = findElementsWithFrequencyK(words, 3);
      expect(result.toSet(), <String>{'apple', 'banana'});
    });

    test('throws on empty list', () {
      expect(() => findElementsWithFrequencyK(<int>[], 1), throwsArgumentError);
    });

    test('throws when k <= 0', () {
      expect(
        () => findElementsWithFrequencyK(<int>[1], 0),
        throwsArgumentError,
      );
    });

    test('works with complex objects', () {
      final List<int> a = <int>[1];
      final List<int> b = <int>[2];
      final List<int> c = <int>[1];
      final List<List<int>> list = <List<int>>[a, b, c, a];
      final List<List<int>> result = findElementsWithFrequencyK(list, 2);
      expect(result.length, 1);
      expect(result[0], same(a));
    });
  });
}
