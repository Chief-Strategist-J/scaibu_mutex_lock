import 'package:test/test.dart';

/// Finds the minimum element in a rotated sorted array.
/// Assumes no duplicate elements.
/// Throws ArgumentError if list is empty.
T findMinimumInRotatedSortedArray<T extends Comparable<dynamic>>(
  final List<T> list,
) {
  if (list.isEmpty) {
    throw ArgumentError('List cannot be empty');
  }

  int left = 0;
  int right = list.length - 1;

  // If array is not rotated (sorted ascending), the first element is minimum
  if (list[left].compareTo(list[right]) < 0) {
    return list[left];
  }

  // Binary search for the minimum element (rotation point)
  while (left < right) {
    final int mid = left + ((right - left) >> 1);

    // If mid element > right element, minimum is in right half excluding mid
    if (list[mid].compareTo(list[right]) > 0) {
      left = mid + 1;
    } else {
      // Minimum is in left half including mid
      right = mid;
    }
  }

  return list[left];
}

void main() {
  group('findMinimumInRotatedSortedArray', () {
    test('minimum in rotated integer array', () {
      final List<int> arr = <int>[4, 5, 6, 7, 0, 1, 2];
      expect(findMinimumInRotatedSortedArray(arr), 0);
    });

    test('minimum in non-rotated sorted array', () {
      final List<int> arr = <int>[1, 2, 3, 4, 5];
      expect(findMinimumInRotatedSortedArray(arr), 1);
    });

    test('minimum when rotated at last element', () {
      final List<int> arr = <int>[2, 3, 4, 5, 1];
      expect(findMinimumInRotatedSortedArray(arr), 1);
    });

    test('single element array', () {
      final List<int> arr = <int>[10];
      expect(findMinimumInRotatedSortedArray(arr), 10);
    });

    test('throws ArgumentError on empty list', () {
      expect(
        () => findMinimumInRotatedSortedArray<int>(<int>[]),
        throwsArgumentError,
      );
    });

    test('minimum in rotated array of doubles', () {
      final List<double> arr = <double>[3.2, 4.5, 5.6, 0.5, 1.1, 2.2];
      expect(findMinimumInRotatedSortedArray(arr), 0.5);
    });

    test('minimum in rotated array of strings', () {
      final List<String> arr = <String>[
        'date',
        'fig',
        'grape',
        'apple',
        'banana',
        'cherry',
      ];
      expect(findMinimumInRotatedSortedArray(arr), 'apple');
    });
  });
}
