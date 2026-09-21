// //task2
// void main() {

//   int age = 21;
//   double gpa = 3.75;
//   String country = 'Canada';
//   bool isStudent = true;

//   print('Age: $age');
//   print('GPA: $gpa');
//   print('Country: $country');
//   print('Is Student: $isStudent');
// }

// //task3

// void main() {
//   // 1. FINAL: Works because final is evaluated at RUN
//   // DateTime.now() is only known when the program actually runs.
//   final DateTime currentTime = DateTime.now();
//   print('Final time (runtime): $currentTime');

//   // 2. CONST: Causes a compile-time error!
//   // const DateTime compileTime = DateTime.now(); 
//   // Error: Const variables must be initialized with a constant value.
  
//   print('\nWhy const fails here:');
//   print('`const` requires values to be known at compile-time (before the app runs).');
//   print('`DateTime.now()` changes every second and can only be known at runtime.');
// }

// //task4
// void main() {
//   String nonNullableUsername = 'DartDeveloper';

//   String? nullableNickname; // Currently null


//   String displayNameA = nullableNickname ?? 'GuestUser';
//   print('Username: $nonNullableUsername');
//   print('Nickname A (Fallback Triggered): $displayNameA'); // Prints 'GuestUser'

//   nullableNickname = 'CodeMaster';

//   String displayNameB = nullableNickname ?? 'GuestUser';
//   print('Nickname B (Value Exists): $displayNameB'); // Prints 'CodeMaster'
// }