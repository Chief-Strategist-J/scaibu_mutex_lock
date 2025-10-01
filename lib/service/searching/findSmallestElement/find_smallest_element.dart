import 'package:test/test.dart';

/// Generic reusable function to find the smallest
/// element in a List<T>
T findSmallestElement<T extends Comparable<dynamic>>(final List<T> list) {
  if (list.isEmpty) {
    throw ArgumentError('List cannot be empty');
  }

  T smallest = list[0];
  for (final T element in list) {
    if (element.compareTo(smallest) < 0) {
      smallest = element;
    }
  }
  return smallest;
}

void main() {
  group('findSmallestElement', () {
    test('find smallest in list of integers', () {
      final List<int> nums = <int>[1, 5, 3, 9, 2];
      expect(findSmallestElement(nums), 1);
    });

    test('find smallest in list of doubles', () {
      final List<double> nums = <double>[1.5, 2.3, 0.7, 4.1];
      expect(findSmallestElement(nums), 0.7);
    });

    test('find smallest in list of strings', () {
      final List<String> words = <String>['apple', 'banana', 'pear', 'orange'];
      expect(findSmallestElement(words), 'apple');
    });

    test('throws ArgumentError on empty list', () {
      expect(
        () => findSmallestElement<double>(<double>[]),
        throwsArgumentError,
      );
    });

    test('find smallest with negative numbers', () {
      final List<int> nums = <int>[-10, -3, -50, -1];
      expect(findSmallestElement(nums), -50);
    });
  });
}
