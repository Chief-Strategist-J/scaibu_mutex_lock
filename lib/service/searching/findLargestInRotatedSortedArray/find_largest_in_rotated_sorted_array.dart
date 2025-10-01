import 'package:test/test.dart';

/// Finds the largest element in a rotated sorted array.
/// Assumes no duplicate elements.
/// Throws ArgumentError if list is empty.
T findLargestInRotatedSortedArray<T extends Comparable<dynamic>>(
  final List<T> list,
) {
  if (list.isEmpty) {
    throw ArgumentError('List cannot be empty');
  }

  int left = 0;
  int right = list.length - 1;

  // If array is not rotated (sorted ascending), the last element is largest
  if (list[left].compareTo(list[right]) < 0) {
    return list[right];
  }

  // Binary search for rotation point - largest element
  while (left < right) {
    final int mid = left + ((right - left) >> 1);

    // If mid element > right element, largest must be
    // on right side including mid
    if (list[mid].compareTo(list[right]) > 0) {
      left = mid + 1;
    } else {
      // Largest is in left half including mid
      right = mid;
    }
  }
  // At this point, left points to the smallest element (rotation point),
  // so largest is the element before it (consider wrap-around)
  final int largestIndex = (left - 1 + list.length) % list.length;
  return list[largestIndex];
}

void main() {
  group('findLargestInRotatedSortedArray', () {
    test('largest in rotated integer array', () {
      final List<int> arr = <int>[4, 5, 6, 7, 0, 1, 2];
      expect(findLargestInRotatedSortedArray(arr), 7);
    });

    test('largest in non-rotated sorted array', () {
      final List<int> arr = <int>[1, 2, 3, 4, 5];
      expect(findLargestInRotatedSortedArray(arr), 5);
    });

    test('largest when rotated at last element', () {
      final List<int> arr = <int>[2, 3, 4, 5, 1];
      expect(findLargestInRotatedSortedArray(arr), 5);
    });

    test('single element array', () {
      final List<int> arr = <int>[10];
      expect(findLargestInRotatedSortedArray(arr), 10);
    });

    test('throws ArgumentError on empty list', () {
      expect(
        () => findLargestInRotatedSortedArray<int>(<int>[]),
        throwsArgumentError,
      );
    });

    test('largest in rotated array of doubles', () {
      final List<double> arr = <double>[3.2, 4.5, 5.6, 0.5, 1.1, 2.2];
      expect(findLargestInRotatedSortedArray(arr), 5.6);
    });

    test('largest in rotated array of strings', () {
      final List<String> arr = <String>[
        'date',
        'fig',
        'grape',
        'apple',
        'banana',
        'cherry',
      ];
      expect(findLargestInRotatedSortedArray(arr), 'grape');
    });
  });
}
