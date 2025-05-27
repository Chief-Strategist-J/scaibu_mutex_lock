import 'package:test/test.dart';

/// Returns a list of elements that appear exactly k times in the input list.
List<T> findElementsRepeatedExactlyKTimes<T>(final List<T> list, final int k) {
  if (k <= 0) {
    throw ArgumentError('k must be greater than 0');
  }

  final Map<T, int> countMap = <T, int>{};

  for (final T element in list) {
    countMap[element] = (countMap[element] ?? 0) + 1;
  }

  return countMap.entries
      .where((final MapEntry<T, int> entry) => entry.value == k)
      .map((final MapEntry<T, int> entry) => entry.key)
      .toList();
}

void main() {
  group('findElementsRepeatedExactlyKTimes', () {
    test('finds elements repeated exactly k times', () {
      final List<int> nums = <int>[1, 2, 2, 3, 3, 3, 4];
      expect(findElementsRepeatedExactlyKTimes(nums, 2), <int>[2]);
      expect(findElementsRepeatedExactlyKTimes(nums, 3), <int>[3]);
    });

    test('returns empty list when no elements match k', () {
      final List<int> nums = <int>[1, 1, 1];
      expect(findElementsRepeatedExactlyKTimes(nums, 2), <dynamic>[]);
    });

    test('handles string list correctly', () {
      final List<String> words = <String>[
        'a',
        'b',
        'a',
        'b',
        'b',
        'c',
        'd',
        'd',
      ];
      expect(findElementsRepeatedExactlyKTimes(words, 2), <String>['a', 'd']);
    });

    test('returns empty list for empty input', () {
      expect(findElementsRepeatedExactlyKTimes(<int>[], 1), <dynamic>[]);
    });

    test('throws for invalid k', () {
      expect(
        () => findElementsRepeatedExactlyKTimes(<int>[1, 2], 0),
        throwsArgumentError,
      );
    });

    test('handles case where element appears once', () {
      final List<int> nums = <int>[5, 6, 5, 7, 8];
      expect(findElementsRepeatedExactlyKTimes(nums, 1), <int>[6, 7, 8]);
    });
  });
}
