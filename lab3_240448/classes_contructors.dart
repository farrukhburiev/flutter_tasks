//task2
class Person{
  String name;
  int age;

  Person(this.name, this.age);
}

//task3
class Square{
  final double side;

  Square(double side): side = side>0 ? side : throw ArgumentError('Side length must be positive');

}

//task4
class DatabaseService{
  static final DatabaseService _instance = DatabaseService._internal();

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }
}

//task5

class BankAccount {
  // Private backing field to protect internal data
  double _balance = 0.0;

  // Custom getter to read the balance safely
  double get balance => _balance;

  // Custom setter with domain constraints (preventing negative deposits/balances)
  set balance(double newBalance) {
    if (newBalance >= 0) {
      _balance = newBalance;
    } else {
      print('Constraint Error: Balance cannot be set to a negative value.');
    }
  }
}

// void main() {
//   var account = BankAccount();
  
//   account.balance = 250.0; // Triggers setter successfully
//   print('Current Balance: \$${account.balance}'); 

//   account.balance = -50.0; // Triggers domain constraint error
// }


//task6
class UserProfileDto {
  final String username;
  final String email;

  // A const constructor makes instances compile-time constants when given literal values
  const UserProfileDto({
    required this.username,
    required this.email,
  });
}

void main() {
  // Creating a fully immutable data transfer object (DTO)
  const user = UserProfileDto(
    username: 'farrukh_dev',
    email: 'farrukh@dart.dev',
  );

  print('User: ${user.username} (${user.email})');
  
  // user.username = 'new_name'; // Error! Fields are final and cannot be modified.
}