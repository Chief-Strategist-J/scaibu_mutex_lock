import 'package:test/test.dart';

/// Generic reusable function to find the k-th largest
/// element in a List<T>
/// Throws ArgumentError if k is out of range or list is empty.
T findKthLargest<T extends Comparable<dynamic>>(
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
    ..sort((final T a, final T b) => b.compareTo(a)); // descending order

  return sortedList[k - 1];
}

void main() {
  group('findKthLargest', () {
    test('find 2nd largest in list of integers', () {
      final List<int> nums = <int>[1, 5, 3, 9, 2];
      expect(findKthLargest(nums, 2), 5);
    });

    test('find 3rd largest in list of doubles', () {
      final List<double> nums = <double>[1.5, 2.3, 0.7, 4.1, 3.3];
      expect(findKthLargest(nums, 3), 2.3);
    });

    test('find k-th largest in list of strings', () {
      final List<String> words = <String>['apple', 'banana', 'pear', 'orange'];
      expect(
        findKthLargest(words, 3),
        'banana',
      ); // descending: pear, orange, banana, apple
    });

    test('throws ArgumentError on empty list', () {
      expect(() => findKthLargest<double>(<double>[], 1), throwsArgumentError);
    });

    test('throws ArgumentError when k out of range (too small)', () {
      final List<int> nums = <int>[1, 2, 3];
      expect(() => findKthLargest(nums, 0), throwsArgumentError);
    });

    test('throws ArgumentError when k out of range (too large)', () {
      final List<int> nums = <int>[1, 2, 3];
      expect(() => findKthLargest(nums, 4), throwsArgumentError);
    });

    test('find largest when k = 1', () {
      final List<int> nums = <int>[7, 2, 9, 4];
      expect(findKthLargest(nums, 1), 9);
    });

    test('find smallest when k = length of list', () {
      final List<int> nums = <int>[7, 2, 9, 4];
      expect(findKthLargest(nums, nums.length), 2);
    });

    test('find k-th largest with duplicates', () {
      final List<int> nums = <int>[5, 3, 5, 2, 1];
      expect(findKthLargest(nums, 2), 5);
      expect(findKthLargest(nums, 3), 3);
    });
  });
}
