//task2
abstract class Shape {
  double area();
}

class Circle implements Shape {
  final double radius;
  const Circle(this.radius);

  @override
  double area() => 3.14159 * radius * radius;
}

class Rectangle implements Shape {
  final double width, height;
  const Rectangle(this.width, this.height);

  @override
  double area() => width * height;
}

// void main() {
//   List<Shape> shapes = [
//     const Circle(5.0),
//     const Rectangle(4.0, 6.0),
//   ];

//   for (var shape in shapes) {
//     print('Shape area: ${shape.area()}');
//   }
// }


//task3
abstract class Animal {
  void makeNoise();
}

class Dog extends Animal {
  @override
  void makeNoise() => print('Woof! Woof!');
  
  void fetch() => print('Dog is fetching the ball...');
}

class Cat extends Animal {
  @override
  void makeNoise() => print('Meow...');
}

void processAnimal(Animal animal) {
  animal.makeNoise();

  // Runtime type check using 'is'
  if (animal is Dog) {
    // Type casting using 'as' to access Dog-specific methods safely
    (animal as Dog).fetch();
  }
}

// void main() {
//   Animal myDog = Dog();
//   Animal myCat = Cat();

//   processAnimal(myDog);
//   processAnimal(myCat);
// }


//task4
class Repository<T> {
  final List<T> _items = [];

  void add(T item) {
    _items.add(item);
    print('Item added to repository.');
  }

  List<T> getAll() => _items;
}

// void main() {
//   var stringRepo = Repository<String>();
//   stringRepo.add('Farrukh');
  
//   print('Repository items: ${stringRepo.getAll()}');
// }


//task5
sealed class NetworkResult {}

class Success extends NetworkResult {
  final String data;
  Success(this.data);
}

class Failure extends NetworkResult {
  final String errorMessage;
  Failure(this.errorMessage);
}

String handleResponse(NetworkResult result) {
  // Exhaustive switch expression using a sealed class hierarchy
  return switch (result) {
    Success(data: var d) => 'Success: $d',
    Failure(errorMessage: var err) => 'Error occurred: $err',
  };
}

// void main() {
//   NetworkResult res = Success('Dashboard payload loaded');
//   print(handleResponse(res));
// }


//task6
abstract interface class SortingStrategy {
  List<int> sort(List<int> data);
}

class BubbleSort implements SortingStrategy {
  @override
  List<int> sort(List<int> data) {
    print('Executing Bubble Sort algorithm...');
    data.sort();
    return data;
  }
}

class QuickSort implements SortingStrategy {
  @override
  List<int> sort(List<int> data) {
    print('Executing Quick Sort algorithm...');
    data.sort();
    return data;
  }
}

class SorterContext {
  SortingStrategy _strategy;

  SorterContext(this._strategy);

  void setStrategy(SortingStrategy newStrategy) {
    _strategy = newStrategy;
  }

  List<int> performSort(List<int> items) => _strategy.sort(items);
}

void main() {
  var sorter = SorterContext(QuickSort());
  sorter.performSort([9, 3, 1, 5, 2]);

  // Dynamically switching strategy at runtime
  sorter.setStrategy(BubbleSort());
  sorter.performSort([8, 4, 6]);
}