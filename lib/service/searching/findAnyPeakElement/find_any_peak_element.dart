import 'package:test/test.dart';

/// Finds any peak element index in the list.
/// A peak element is one that is not smaller than its neighbors.
/// If multiple peaks exist, returns any one of them.
/// Throws ArgumentError if list is empty.
int findAnyPeakElement(final List<int> list) {
  if (list.isEmpty) {
    throw ArgumentError('List cannot be empty');
  }
  int left = 0;
  int right = list.length - 1;

  while (left < right) {
    final int mid = left + (right - left) ~/ 2;

    if (list[mid] < list[mid + 1]) {
      left = mid + 1;
    } else {
      right = mid;
    }
  }
  return left;
}

void main() {
  group('findAnyPeakElement', () {
    test('finds peak in middle', () {
      final List<int> nums = <int>[1, 3, 20, 4, 1, 0];
      final int peakIndex = findAnyPeakElement(nums);
      final bool isPeak =
          (peakIndex == 0 || nums[peakIndex] >= nums[peakIndex - 1]) &&
          (peakIndex == nums.length - 1 ||
              nums[peakIndex] >= nums[peakIndex + 1]);
      expect(isPeak, isTrue);
    });

    test('finds peak at start', () {
      final List<int> nums = <int>[10, 5, 2];
      final int peakIndex = findAnyPeakElement(nums);
      final bool isPeak =
          (peakIndex == 0 || nums[peakIndex] >= nums[peakIndex - 1]) &&
          (peakIndex == nums.length - 1 ||
              nums[peakIndex] >= nums[peakIndex + 1]);
      expect(isPeak, isTrue);
    });

    test('finds peak at end', () {
      final List<int> nums = <int>[1, 3, 5, 7, 9];
      final int peakIndex = findAnyPeakElement(nums);
      final bool isPeak =
          (peakIndex == 0 || nums[peakIndex] >= nums[peakIndex - 1]) &&
          (peakIndex == nums.length - 1 ||
              nums[peakIndex] >= nums[peakIndex + 1]);
      expect(isPeak, isTrue);
    });

    test('single element is peak', () {
      final List<int> nums = <int>[42];
      expect(findAnyPeakElement(nums), 0);
    });

    test('throws on empty list', () {
      expect(() => findAnyPeakElement(<int>[]), throwsArgumentError);
    });

    test('works with multiple peaks', () {
      final List<int> nums = <int>[1, 3, 2, 4, 3, 5, 4];
      final int peakIndex = findAnyPeakElement(nums);
      final bool isPeak =
          (peakIndex == 0 || nums[peakIndex] >= nums[peakIndex - 1]) &&
          (peakIndex == nums.length - 1 ||
              nums[peakIndex] >= nums[peakIndex + 1]);
      expect(isPeak, isTrue);
    });
  });
}
