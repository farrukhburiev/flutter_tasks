//task2
abstract interface class DBConnector {
  void connect();
  void disconnect();
}

class MySQLConnector implements DBConnector {
  @override
  void connect() => print('connecting to db MySQL...');

  @override
  void disconnect() => print('disconnecting from MySQL database...');
}

// void main() {
//   var db = MySQLConnector();
//   db.connect();
//   db.disconnect();
// }

//task3
mixin Flyable {
  void fly() => print('Flying high in the sky...');
}

class Bird with Flyable {
  final String name;
  Bird(this.name);
}

// void main() {
//   var parrot = Bird('Parrot');
//   print('${parrot.name}:');
//   parrot.fly();
// }


//task4
mixin Walker {
  void walk() => print('Walking on the ground...');
}

mixin Swimmer {
  void swim() => print('Swimming in the water...');
}

mixin Flyer {
  void fly() => print('Flying in the sky...');
}

class Duck with Walker, Swimmer, Flyer {}

// void main() {
//   var donald = Duck();
//   donald.walk();
//   donald.swim();
//   donald.fly();
// }

//task5
class Animal {
  void breathe() => print('Breathe...');
}


mixin Runner on Animal {
  void run() => print('Run fast...');
}

class Cheetah extends Animal with Runner {}

// void main() {
//   var cheetah = Cheetah();
//   cheetah.breathe();
//   cheetah.run();
// }

//task6

abstract interface class Speaker {
  void speak();
}

class Human implements Speaker {
  @override
  void speak() => print('Human is speaking.');
}


mixin Logger {
  void log() => print('Logging data to log...');
}

class SystemReport with Logger {}

void main() {
  var human = Human();
  human.speak();

  var report = SystemReport();
  report.log(); 
}