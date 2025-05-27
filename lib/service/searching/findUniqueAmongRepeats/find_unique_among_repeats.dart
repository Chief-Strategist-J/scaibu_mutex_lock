import 'package:test/test.dart';

/// Finds the unique element in a list where every other element appears
/// exactly `repeatCount` times.
/// Assumes exactly one unique element exists.
/// Works for integers using bitwise operations.
/// Throws ArgumentError if repeatCount < 2.
int findUniqueAmongRepeats(final List<int> list, final int repeatCount) {
  if (repeatCount < 2) {
    throw ArgumentError('repeatCount must be at least 2');
  }
  if (list.isEmpty) {
    throw RangeError('List cannot be empty');
  }

  int result = 0;
  for (int i = 0; i < 32; i++) {
    int sumBits = 0;
    for (final int num in list) {
      sumBits += (num >> i) & 1;
    }
    if (sumBits % repeatCount != 0) {
      result |= 1 << i;
    }
  }
  return result;
}

void main() {
  group('findUniqueAmongRepeats', () {
    test('finds unique when others repeated 3 times', () {
      final List<int> nums = <int>[6, 1, 3, 3, 3, 6, 6];
      expect(findUniqueAmongRepeats(nums, 3), 1);
    });

    test('finds unique when others repeated 2 times', () {
      final List<int> nums = <int>[2, 2, 3, 4, 4];
      expect(findUniqueAmongRepeats(nums, 2), 3);
    });

    test('finds unique when others repeated 4 times', () {
      final List<int> nums = <int>[5, 5, 5, 5, 9, 9, 9, 9, 42];
      expect(findUniqueAmongRepeats(nums, 4), 42);
    });

    test('throws if repeatCount < 2', () {
      final List<int> nums = <int>[1, 2, 3];
      expect(() => findUniqueAmongRepeats(nums, 1), throwsArgumentError);
    });

    test('throws on empty list', () {
      expect(() => findUniqueAmongRepeats(<int>[], 3), throwsRangeError);
    });

    test('works with negative unique', () {
      final List<int> nums = <int>[-7, -7, -7, 10];
      expect(findUniqueAmongRepeats(nums, 3), 10);
    });
  });
}
