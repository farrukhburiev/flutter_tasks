//task1
// void main() {
//   print('Farrux Buriyev');
//   print('Student id:240448');
//   print('Major:Computer Science');
// }

//task2
// void main(List<String> arguments) {
//   print('Total command-line arguments: ${arguments.length}');
//   if (arguments.isNotEmpty) {
//     print('Arguments list: ${arguments.join(",")}');
//   }
// }

//task3
// void main(List<String> arguments) {
//   if (arguments.isEmpty) {
//     print('u have not entered any numbers');
//     return;
//   }

//   double sum = 0;
//   int numbersCount = 0;
  

//   for (var arg in arguments){
//     double? number = double.tryParse(arg);
//     if (number != null){
//       sum+=number;
//       numbersCount++;
//     }
//   }
//   double average = sum/numbersCount;
//   print('The average of the entered numbers is: $average');
//   print('The sum of the entered numbers is: $sum');
// }

// //task6
// import 'dart:io';
// void main(List<String> arguments) {
//   if (arguments.isEmpty) {
//     print('Error: No arguments provided!');
//     exitCode = 1;
//     return;
//   }

//   print('Successfully processed arguments: ${arguments.join(", ")}');
//   exitCode = 0;
// }
