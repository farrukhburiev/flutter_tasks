//task2
// 1. Base (Parent) class
// class Animal {
//   final String name;

//   Animal(this.name);

//   void makeSound() {
//     print('$name makes a generic animal sound.');
//   }
// }

// // 2. Derived (Child) class using 'extends'
// class Dog extends Animal {
//   Dog(String name) : super(name);

//   // 3. Overriding the parent's method with custom behavior
//   @override
//   void makeSound() {
//     print('$name barks: Woof! Woof!');
//   }
// }

// void main() {
//   var myDog = Dog('Buddy');
//   myDog.makeSound(); // Output: Buddy barks: Woof! Woof!
// }

//task3 

// 1. Base (Parent) class
class Animal {
  final String name;

  Animal(this.name);

  void makeSound() {
    print('$name makes a generic animal sound.');
  }
}

// 2. Derived (Child) class using 'extends'
class Dog extends Animal {
  Dog(String name) : super(name);

  // 3. Overriding the parent's method with custom behavior
  @override
  void makeSound() {
    print('$name barks: Woof! Woof!');
  }
}

// void main() {
//   var myDog = Dog('Buddy');
//   myDog.makeSound(); // Output: Buddy barks: Woof! Woof!
// }


//task4
class Shape {
  void render() => print('Rendering shape...');
}

class Polygon extends Shape {
  final int sides;
  Polygon(this.sides);

  @override
  void render() {
    super.render();
    print('Polygon has $sides sides.');
  }
}

class Triangle extends Polygon {
  // Triangle passes 3 up to the Polygon constructor
  Triangle() : super(3);

  @override
  void render() {
    super.render();
    print('Specific shape: Triangle.');
  }
}

// void main() {
//   var t = Triangle();
//   t.render();
// }


//task5

abstract class Employee {
  final String name;
  Employee(this.name);

  // Concrete method (has a body, inherited as-is)
  void clockIn() => print('$name clocked in for work.');

  // Abstract method (no body; subclasses are forced to implement it)
  double calculatePay();
}

class Manager extends Employee {
  Manager(super.name);

  @override
  double calculatePay() => 8500.0; // Enforced implementation
}

// void main() {
//   // var emp = Employee('John'); // Error! Abstract classes cannot be instantiated directly.
//   var mgr = Manager('Alice');
//   mgr.clockIn();
//   print('Pay: \$${mgr.calculatePay()}');
// }


//task6
// 1. A 'final class' completely prevents subclassing outside of this library file
final class SecureConfiguration {
  final String environment = 'Production';

  // 2. A final method cannot be overridden by any subclasses
//   final void loadConfig() => print('Loading secure settings...'); //gives error
}

// class HackAttempt extends SecureConfiguration {} // COMPILE ERROR: Cannot extend a final class