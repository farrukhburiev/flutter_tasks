// //task2
// void main() {
//   int number = -5;

//   // If-else chain to evaluate the sign of the integer
//   if (number > 0) {
//     print('$number is positive.');
//   } else if (number < 0) {
//     print('$number is negative.');
//   } else {
//     print('The number is zero.');
//   }
// }

// //task3

// void main() {
//   int n = 5;

//   // 1. Using a standard for loop
//   int factorialStandard = 1;
//   for (int i = 1; i <= n; i++) {
//     factorialStandard *= i;
//   }
//   print('Factorial of $n (using standard for loop) = $factorialStandard');

//   // 2. Using a for-in loop (iterating over a generated list from 1 to n)
//   int factorialForIn = 1;
//   List<int> numbers = [for (int i = 1; i <= n; i++) i];
  
//   for (var num in numbers) {
//     factorialForIn *= num;
//   }
//   print('Factorial of $n (using for-in loop) = $factorialForIn');
// }

// //task4
// import 'dart:math';

// void main() {
//   int targetValue = 42;
//   int currentGuess = 0;
//   int attempts = 0;
  
//   Random random = Random();

//   print('Starting guess-the-number simulation (Target: $targetValue)...');

//   while (true) {
//     attempts++;
//     // Simulate a random guess between 1 and 100
//     currentGuess = random.nextInt(100) + 1;
    
//     print('Attempt $attempts: Guessed $currentGuess');

//     if (currentGuess == targetValue) {
//       print('Success! Found the target value $targetValue in $attempts attempts.');
//       break; // Exit the loop when the target value is reached
//     }
//   }
// }

// //task5
// void main() {
//   // Define a label for the outer loop
//   outerLoop: 
//   for (int i = 1; i <= 3; i++) {
//     print('Outer loop iteration: $i');
    
//     for (int j = 1; j <= 3; j++) {
//       print('  Inner loop iteration: $j');
      
//       // Example of using 'continue' with a label to skip to the next iteration of the outer loop
//       if (i == 2 && j == 1) {
//         print('  -> Skipping rest of outer iteration 2 via labeled continue.');
//         continue outerLoop;
//       }

//       // Example of using 'break' with a label to completely break out of the outer loop
//       if (i == 3 && j == 2) {
//         print('  -> Breaking completely out of all loops via labeled break.');
//         break outerLoop;
//       }
//     }
//   }
//   print('Exited all loops safely.');
// }