//task2
double divideNumbers(int numerator, int denominator) {
  try {
    if (denominator == 0) {
      throw UnsupportedError('Division by zero is not supported.');
    }
    return numerator / denominator;
  } on UnsupportedError catch (e) {
    print('Caught specific error: ${e.message}');
    return 0.0; // Fallback value
  }
}

// void main() {
//   double result = divideNumbers(10, 0);
//   print('Result: $result');
// }

//task3
void validateAndProcessString(String? input) {
  if (input == null || input.isEmpty) {
    throw ArgumentError('Parameter cannot be null or empty.');
  }
  print('Successfully processed: $input');
}

// void main() {
//   try {
//     validateAndProcessString('');
//   } catch (e) {
//     print('Caught error: $e');
//   }
// }


//task4
void performOperation(int type) {
  try {
    if (type == 1) {
      throw FormatException('Invalid data format received.');
    } else {
      throw Exception('An unexpected system error occurred.');
    }
  } on FormatException catch (e) {
    print('Handling FormatException: ${e.message}');
  } catch (e) {
    print('Handling generic exception: $e');
  }
}

// void main() {
//   performOperation(1);
// }



//task5
void causeError() {
  throw StateError('The application is in an invalid state.');
}

// void main() {
//   try {
//     causeError();
//   } catch (e, stackTrace) {
//     print('Error message: $e');
//     print('--- Full Stack Trace ---');
//     print(stackTrace);
//   }
// }

//task6
void connectToDatabase() {
  try {
    // Simulating a failed connection attempt
    throw Exception('Connection timeout');
  } catch (e) {
    print('Log: Error caught locally, logging to crashlytics...');
    rethrow; // Passes the original exception further up the call stack
  }
}

void main() {
  try {
    connectToDatabase();
  } catch (e) {
    print('Caught rethrown exception in main: $e');
  }
}