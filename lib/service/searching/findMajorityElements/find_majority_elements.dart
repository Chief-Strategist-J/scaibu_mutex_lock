import 'package:test/test.dart';

/// Returns a list of elements that appear more than n/2 times in the list.
/// For a single majority element, returns a list with one element.
/// If no such element exists, returns an empty list.
List<T> findMajorityElements<T>(final List<T> list) {
  final Map<T, int> counts = <T, int>{};
  final int threshold = list.length ~/ 2;

  for (final T element in list) {
    counts[element] = (counts[element] ?? 0) + 1;
  }

  return counts.entries
      .where((final MapEntry<T, int> entry) => entry.value > threshold)
      .map((final MapEntry<T, int> e) => e.key)
      .toList();
}

void main() {
  group('findMajorityElements', () {
    test('finds the majority element when it exists', () {
      final List<int> nums = <int>[1, 2, 1, 1, 3, 1];
      expect(findMajorityElements(nums), <int>[1]);
    });

    test('returns empty list when no majority element exists', () {
      final List<int> nums = <int>[1, 2, 3, 4, 5];
      expect(findMajorityElements(nums), <dynamic>[]);
    });

    test('finds majority string', () {
      final List<String> words = <String>['apple', 'apple', 'banana', 'apple'];
      expect(findMajorityElements(words), <String>['apple']);
    });

    test('returns empty list on empty input', () {
      final List<int> nums = <int>[];
      expect(findMajorityElements(nums), <dynamic>[]);
    });

    test('majority element exactly half is not valid', () {
      final List<int> nums = <int>[1, 1, 2, 2];
      expect(findMajorityElements(nums), <dynamic>[]);
    });

    test('finds majority in list with all same elements', () {
      final List<int> nums = <int>[7, 7, 7, 7];
      expect(findMajorityElements(nums), <int>[7]);
    });
  });
}
