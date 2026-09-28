library geometry_utils;

//task2
// void main() {
//   // Single-line comment: Define the radius for the circle calculation
//   double radius = 7.0;

//   /* 
//    * Multi-line comment explaining the step-by-step formula:
//    * 1. Calculate the square of the radius (r * r)
//    * 2. Multiply by pi (3.14159) to find the total area of the circle
//    */
//   double area = 3.14159 * (radius * radius);

//   print('The calculated area is: $area');
// }

//task3
class DataValidator {
  
  ///  */ Validates whether the provided [age] falls within an acceptable human range. 
  /// 
  /// Parameters:
  /// - [age]: An integer representing the user's age in years.
  /// 
  /// Returns:
  /// - `true` if the age is valid.
  /// 
  /// Throws:
  /// - [ArgumentError] if [age] is negative or greater than 150.
  bool validateAge(int age) {
    if (age < 0 || age > 150) {
      throw ArgumentError('Age must be between 0 and 150. Provided: $age');
    }
    return true;
  }
}



//task4

/// A service class to handle **secure user authentication** and session tokens.
/// 
/// ### Key Features
/// * **Encrypted Storage**: Securely saves authentication tokens locally.
/// * **Automatic Expiration Handling**: Refreshes tokens seamlessly when expired.
/// 
/// ### Example Usage
/// ```dart
/// final authService = AuthService();
/// bool success = await authService.login('user@dart.dev', 'securePassword123');
/// 
/// if (success) {
///   print('Login successful!');
/// }
/// ```
class AuthService {
  /// Attempts to log the user in with their credentials.
  Future<bool> login(String email, String password) async {
    // Mock authentication logic
    return true;
  }
}

// void main() {
//   print('AuthService initialized.');
// }

//task5

class Greeter {
  /// Sends a standard greeting message.
  /// 
  /// [name] is the recipient's name.
  String greet(String name) {
    return 'Hello, $name!';
  }

  /// Old greeting method. 
  /// 
  /// Use [greet] instead. This will be removed in version 2.0.
  @deprecated
  String oldGreet(String name) {
    return 'Hi there, $name.';
  }
}

class AdvancedGreeter extends Greeter {
  /// Overrides the standard greeting to include an exclamation prefix.
  @override
  String greet(String name) {
    return 'WELCOME, $name!!';
  }
}

// void main() {
//   var greeter = AdvancedGreeter();
//   print(greeter.greet('Farrukh')); // Output: WELCOME, Farrukh!!
  
//   // IDE will show a warning/strikethrough on this line because it's deprecated
//   // print(greeter.oldGreet('Farrukh')); 
// }

//task6
/// A mathematical utility library designed for handling **2D geometric coordinates**.

/// Represents a point in a 2D Cartesian coordinate system.
/// 
/// Example usage:
/// ```dart
/// var origin = Coordinate.origin();
/// var target = Coordinate(3.0, 4.0);
/// double dist = origin.distanceTo(target);
/// ```
class Coordinate {
  /// The horizontal x-axis value.
  final double x;

  /// The vertical y-axis value.
  final double y;

  /// Creates a standard [Coordinate] with specified [x] and [y] values.
  const Coordinate(this.x, this.y);

  /// Creates a [Coordinate] fixed at the origin point (0, 0).
  const Coordinate.origin() : x = 0.0, y = 0.0;

  /// Calculates the Euclidean distance between this point and [other].
  /// 
  /// Returns a [double] representing the straight-line distance.
  double distanceTo(Coordinate other) {
    double dx = other.x - x;
    double dy = other.y - y;
    // Using standard Pythagorean theorem
    return Math.sqrt(dx * dx + dy * dy); 
  }
}

// Mock math class for compilation context
class Math {
  static double sqrt(double val) => val; // Simplified mock
}