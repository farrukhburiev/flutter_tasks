// //task2
// enum Day {
//   monday,
//   tuesday,
//   wednesday,
//   thursday,
//   friday,
//   saturday,
//   sunday
// }

// void main() {
//   // Using the built-in .values property to loop through every constant in the enum
//   for (var day in Day.values) {
//     print('Current day: $day');
//   }
// }


// //task3
// enum orderStatus {
//   pending,
//   processing,
//   shipped,
//   delivered,
//   cancelled
// }

// String getStatusUILabel(orderStatus status){
//   return switch (status) {
//     orderStatus.pending => 'Your order is pending.',
//     orderStatus.processing => 'Your order is being processed.',
//     orderStatus.shipped => 'Your order has been shipped.',
//     orderStatus.delivered => 'Your order has been delivered.',
//     orderStatus.cancelled => 'Your order has been cancelled.',
//   };
// }


// //task4
// // 1. Define an abstract interface
// abstract interface class Describable {
//   String describe();
// }

// enum Status implements Describable {
//   active('User is currently online'),
//   inactive('User is offline');

//   final String message;
//   const Status(this.message);

//   @override
//   String describe() => 'Current status detail: $message';

//   bool get isActive => this == Status.active;
// }

// void main() {
//   var currentStatus = Status.active;
//   print(currentStatus.describe()); // Output: Current status detail: User is currently online
//   print('Is active? ${currentStatus.isActive}'); // Output: Is active? true
// }

// //task 5

// class Product {
//   double _price = 0.0; // Private backing field

//   // Custom Getter
//   double get price => _price;

//   // Custom Setter with validation logic
//   set price(double newPrice) {
//     if (newPrice >= 0) {
//       _price = newPrice;
//     } else {
//       print('Error: Price cannot be negative.');
//     }
//   }
// }

// void main() {
//   var item = Product();
//   item.price = 50.0;  // Triggers the setter successfully
//   item.price = -10.0; // Triggers the validation error
//   print('Current Price: ${item.price}');
// }


//task6

class ImmutableConfig {
  final String apiUrl;
  final int timeoutSeconds;

  // A const constructor ensures the entire object can be resolved at compile-time
  const ImmutableConfig(this.apiUrl, this.timeoutSeconds);
}

void main() {
  // Creating a compile-time constant instance
  const config = ImmutableConfig('https://api.dart.dev', 30);
  print('Connecting to ${config.apiUrl}');
}