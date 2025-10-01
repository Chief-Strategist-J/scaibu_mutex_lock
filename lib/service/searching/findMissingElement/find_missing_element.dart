import 'package:test/test.dart';

/// Finds the first missing positive integer from a list of distinct integers,
/// starting from 1 up to the max of the list.
/// If all expected elements are present, returns null.
int? findMissingElement(final List<int> list) {
  if (list.isEmpty) {
    return null;
  }

  final Set<int> seen = Set<int>.from(list);
  final int maxVal = list.reduce((final int a, final int b) => a > b ? a : b);

  for (int i = 1; i <= maxVal; i++) {
    if (!seen.contains(i)) {
      return i;
    }
  }

  return null;
}

void main() {
  group('findMissingElement', () {
    test('finds a missing element in middle of range', () {
      final List<int> nums = <int>[3, 7, 1, 2, 8, 4, 5];
      expect(findMissingElement(nums), 6);
    });

    test('finds smallest missing element at beginning', () {
      final List<int> nums = <int>[2, 3, 4];
      expect(findMissingElement(nums), 1);
    });

    test('returns null if no elements missing', () {
      final List<int> nums = <int>[1, 2, 3, 4, 5];
      expect(findMissingElement(nums), null);
    });

    test('works with unsorted input', () {
      final List<int> nums = <int>[10, 12, 11, 14, 13, 16, 15];
      expect(findMissingElement(nums), 1);
    });

    test('returns 1 if only high numbers exist', () {
      final List<int> nums = <int>[5, 6, 7];
      expect(findMissingElement(nums), 1);
    });

    test('returns null for single element equal to 1', () {
      expect(findMissingElement(<int>[1]), null);
    });

    test('returns 1 for empty list', () {
      expect(findMissingElement(<int>[]), null);
    });

    test('ignores negative numbers and still returns 1 if missing', () {
      final List<int> nums = <int>[-2, -1, 0, 2];
      expect(findMissingElement(nums), 1);
    });
  });
}
