import 'package:test/test.dart';

/// Returns the element with the highest frequency in the list.
/// If multiple elements have the same max frequency, returns any one of them.
/// Throws ArgumentError if the list is empty.
T findElementWithMaxFrequency<T>(final List<T> list) {
  if (list.isEmpty) {
    throw ArgumentError('List cannot be empty');
  }

  final Map<T, int> frequencyMap = <T, int>{};
  for (final T element in list) {
    frequencyMap[element] = (frequencyMap[element] ?? 0) + 1;
  }

  T? result;
  int maxFrequency = 0;

  frequencyMap.forEach((final T element, final int frequency) {
    if (frequency > maxFrequency) {
      maxFrequency = frequency;
      result = element;
    }
  });

  return result as T;
}

void main() {
  group('findElementWithMaxFrequency', () {
    test('finds most frequent integer', () {
      final List<int> nums = <int>[1, 2, 3, 2, 4, 2, 5];
      expect(findElementWithMaxFrequency(nums), 2);
    });

    test('finds most frequent string', () {
      final List<String> words = <String>['a', 'b', 'a', 'c', 'a', 'b'];
      expect(findElementWithMaxFrequency(words), 'a');
    });

    test('works when all elements are unique', () {
      final List<int> nums = <int>[10, 20, 30];
      final int result = findElementWithMaxFrequency(nums);
      expect(nums.contains(result), isTrue);
    });

    test('throws on empty list', () {
      expect(() => findElementWithMaxFrequency(<int>[]), throwsArgumentError);
    });

    test('works with one element', () {
      final List<int> nums = <int>[99];
      expect(findElementWithMaxFrequency(nums), 99);
    });

    test('works with complex objects (by reference)', () {
      final List<List<int>> lists = <List<int>>[
        <int>[1],
        <int>[2],
        <int>[1],
        <int>[1],
      ];
      final List<int> result = findElementWithMaxFrequency(lists);
      expect(result, same(lists[0]));
    });
  });
}
