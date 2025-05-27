import 'package:test/test.dart';

/// Finds all peak element indices in the list.
/// A peak element is one that is not smaller than its neighbors.
/// Returns list of all peak indices.
/// Throws ArgumentError if list is empty.
List<int> findAllPeakElements(final List<int> list) {
  if (list.isEmpty) {
    throw ArgumentError('List cannot be empty');
  }

  final List<int> peaks = <int>[];
  for (int i = 0; i < list.length; i++) {
    final bool leftOk = i == 0 || list[i] >= list[i - 1];
    final bool rightOk = i == list.length - 1 || list[i] >= list[i + 1];
    if (leftOk && rightOk) {
      peaks.add(i);
    }
  }
  return peaks;
}

void main() {
  group('findAllPeakElements', () {
    test('finds peaks in middle', () {
      final List<int> nums = <int>[1, 3, 20, 4, 1, 0];
      final List<int> peaks = findAllPeakElements(nums);
      expect(peaks, <int>[2]);
    });

    test('finds multiple peaks', () {
      final List<int> nums = <int>[1, 3, 2, 4, 3, 5, 4];
      final List<int> peaks = findAllPeakElements(nums);
      expect(peaks, <int>[1, 3, 5]);
    });

    test('peak at start and end', () {
      final List<int> nums = <int>[5, 3, 4, 1, 6];
      final List<int> peaks = findAllPeakElements(nums);
      expect(peaks, <int>[0, 2, 4]);
    });

    test('single element is peak', () {
      final List<int> nums = <int>[42];
      expect(findAllPeakElements(nums), <int>[0]);
    });

    test('throws on empty list', () {
      expect(() => findAllPeakElements(<int>[]), throwsArgumentError);
    });

    test('all equal elements are peaks', () {
      final List<int> nums = <int>[2, 2, 2, 2];
      final List<int> peaks = findAllPeakElements(nums);
      expect(peaks, <int>[0, 1, 2, 3]);
    });
  });
}
