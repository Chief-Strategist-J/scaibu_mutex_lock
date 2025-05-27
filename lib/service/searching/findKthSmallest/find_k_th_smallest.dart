import 'package:test/test.dart';

/// Generic reusable function to find the k-th smallest
/// element in a List<T>
/// Throws ArgumentError if k is out of range or list is empty.
T findKthSmallest<T extends Comparable<dynamic>>(
  final List<T> list,
  final int k,
) {
  if (list.isEmpty) {
    throw ArgumentError('List cannot be empty');
  }
  if (k < 1 || k > list.length) {
    throw ArgumentError('k must be between 1 and the length of the list');
  }

  final List<T> sortedList = List<T>.from(list)
    ..sort((final T a, final T b) => a.compareTo(b)); // ascending order

  return sortedList[k - 1];
}

void main() {
  group('findKthSmallest', () {
    test('find 2nd smallest in list of integers', () {
      final List<int> nums = <int>[1, 5, 3, 9, 2];
      expect(findKthSmallest(nums, 2), 2);
    });

    test('find 3rd smallest in list of doubles', () {
      final List<double> nums = <double>[1.5, 2.3, 0.7, 4.1, 3.3];
      expect(findKthSmallest(nums, 3), 2.3);
    });

    test('find k-th smallest in list of strings', () {
      final List<String> words = <String>['apple', 'banana', 'pear', 'orange'];
      expect(
        findKthSmallest(words, 3),
        'orange',
      ); // ascending: apple, banana, orange, pear
    });

    test('throws ArgumentError on empty list', () {
      expect(() => findKthSmallest<double>(<double>[], 1), throwsArgumentError);
    });

    test('throws ArgumentError when k out of range (too small)', () {
      final List<int> nums = <int>[1, 2, 3];
      expect(() => findKthSmallest(nums, 0), throwsArgumentError);
    });

    test('throws ArgumentError when k out of range (too large)', () {
      final List<int> nums = <int>[1, 2, 3];
      expect(() => findKthSmallest(nums, 4), throwsArgumentError);
    });

    test('find smallest when k = 1', () {
      final List<int> nums = <int>[7, 2, 9, 4];
      expect(findKthSmallest(nums, 1), 2);
    });

    test('find largest when k = length of list', () {
      final List<int> nums = <int>[7, 2, 9, 4];
      expect(findKthSmallest(nums, nums.length), 9);
    });

    test('find k-th smallest with duplicates', () {
      final List<int> nums = <int>[5, 3, 5, 2, 1];
      expect(findKthSmallest(nums, 2), 2);
      expect(findKthSmallest(nums, 3), 3);
    });
  });
}
