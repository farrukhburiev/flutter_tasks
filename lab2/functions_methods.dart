// //task2
// bool isEven(int n) => n % 2 == 0;

// void main() {
//   print('Is 4 even? ${isEven(4)}'); // Prints: true
//   print('Is 7 even? ${isEven(7)}'); // Prints: false
// }

// //task3
// // Function utilizing optional positional parameters wrapped in brackets []
// void formatText(String text, [String prefix = '', String suffix = '']) {
//   print('$prefix$text$suffix');
// }

// void main() {
//   formatText('Hello, Dart!');                      // Output: Hello, Dart!
//   formatText('Hello, Dart!', '*** ');               // Output: *** Hello, Dart!
//   formatText('Hello, Dart!', '*** ', ' ***');       // Output: *** Hello, Dart! ***
// }

// //task4
// // Higher-order function accepting a list and a transformation callback function
// List<int> transformNumbers(List<int> numbers, int Function(int) transformer) {
//   List<int> transformedList = [];
//   for (var num in numbers) {
//     transformedList.add(transformer(num));
//   }
//   return transformedList;
// }

// void main() {
//   List<int> inputList = [1, 2, 3, 4, 5];
  
//   // Pass a closure callback that squares each number
//   List<int> squaredList = transformNumbers(inputList, (n) => n * n);
  
//   print('Original: $inputList');
//   print('Squared (Transformed): $squaredList');
// }

// //task5
// int fibonacci(int n) {
//   if (n <= 0) return 0;
//   if (n == 1) return 1;
//   return fibonacci(n - 1) + fibonacci(n - 2);
// }

// void main() {
//   int n = 7;
//   print('The $n-th Fibonacci number is: ${fibonacci(n)}'); // Output: 13 (0, 1, 1, 2, 3, 5, 8, 13)
// }