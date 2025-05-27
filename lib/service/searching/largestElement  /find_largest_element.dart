import 'package:test/test.dart';


/// Generic reusable function to find the largest
/// element in a List<T>
T findLargestElement<T extends Comparable<dynamic>>(final List<T> list) {
  if (list.isEmpty) {
    throw ArgumentError('List cannot be empty');
  }

  T largest = list[0];
  for (final T element in list) {
    if (element.compareTo(largest) > 0) {
      largest = element;
    }
  }
  return largest;
}

void main() {
  group('findLargestElement', () {
    test('find largest in list of integers', () {
      final List<int> nums = <int>[1, 5, 3, 9, 2];
      expect(findLargestElement(nums), 9);
    });

    test('find largest in list of doubles', () {
      final List<double> nums = <double>[1.5, 2.3, 0.7, 4.1];
      expect(findLargestElement(nums), 4.1);
    });

    test('find largest in list of strings', () {
      final List<String> words = <String>['apple', 'banana', 'pear', 'orange'];
      expect(findLargestElement(words), 'pear');
    });

    test('throws ArgumentError on empty list', () {
      expect(() => findLargestElement<double>(<double>[]), throwsArgumentError);
    });

    test('find largest with negative numbers', () {
      final List<int> nums = <int>[-10, -3, -50, -1];
      expect(findLargestElement(nums), -1);
    });
  });
}