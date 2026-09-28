import 'dart:async';

//task2
Future<String> fetchDatabaseUser() async {
  // Simulate a network or database latency of 2 seconds
  await Future.delayed(const Duration(seconds: 2));
  return 'UserRecord: ID_8492, Status: Active';
}

// void main() async {
//   print('Fetching user from database...');
//   final user = await fetchDatabaseUser();
//   print(user);
// }


//task3
Future<String> taskOne() async {
  await Future.delayed(const Duration(seconds: 1));
  return 'Result from Task 1';
}

Future<String> taskTwo() async {
  await Future.delayed(const Duration(seconds: 2));
  return 'Result from Task 2';
}

Future<String> taskThree() async {
  await Future.delayed(const Duration(seconds: 15));
  return 'Result from Task 3';
}

// void runConcurrentTasks() async {
//   print('Starting concurrent tasks...');
  
//   // Runs all three futures in parallel and waits for all of them to complete
//   final results = await Future.wait([
//     taskOne(),
//     taskTwo(),
//     taskThree(),
//   ]);

//   print('All tasks completed:');
//   for (var result in results) {
//     print('- $result');
//   }
// }


//task4


// void listenToPeriodicTicks() {
//   late StreamSubscription<int> subscription;

//   // Stream.periodic emits an event every specified duration
//   subscription = Stream.periodic(
//     const Duration(seconds: 1), 
//     (computationCount) => computationCount + 1,
//   ).listen((tick) {
//     print('Timer Tick: $tick');

//     // Cancel the subscription after 5 emissions
//     if (tick >= 5) {
//       subscription.cancel();
//       print('Stream subscription successfully cancelled.');
//     }
//   });
// }


//task5
// void transformStreamPipeline() {
//   Stream.fromIterable([1, 2, 2, 3, 4, 4, 5, 6, 8, 10])
//       .where((number) => number % 2 == 0)      // Keep only even numbers: [2, 2, 4, 4, 6, 8, 10]
//       .map((number) => number * 10)            // Multiply each by 10: [20, 20, 40, 40, 60, 80, 100]
//       .distinct()                              // Remove consecutive duplicates: [20, 40, 60, 80, 100]
//       .listen((transformedValue) {
//         print('Processed Value: $transformedValue');
//       });
// }




//task6
void handleStreamErrors() {
  Stream.periodic(const Duration(milliseconds: 500), (index) {
    if (index == 2) {
      throw Exception('Simulated stream error at tick $index');
    }
    return index;
  })
  .take(5) // Limit to 5 emissions
  .handleError((error, stackTrace) {
    // Intercept and handle errors gracefully without crashing the stream listener
    print('Caught error in pipeline: $error');
  })
  .listen(
    (data) => print('Received data: $data'),
    onDone: () => print('Stream closed successfully.'),
  );
}