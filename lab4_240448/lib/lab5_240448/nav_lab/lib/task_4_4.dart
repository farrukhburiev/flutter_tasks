import 'package:flutter/material.dart';

class User {
  final String name;
  final int age;
  final String city;
  const User({required this.name, required this.age, required this.city});
}

const users = [
  User(name: 'Aziz', age: 21, city: 'Tashkent'),
  User(name: 'Madina', age: 24, city: 'Samarkand'),
  User(name: 'Jasur', age: 19, city: 'Bukhara'),
  User(name: 'Nilufar', age: 27, city: 'Namangan'),
];

Widget buildApp() {
  return MaterialApp(
    initialRoute: '/',
    onGenerateRoute: (settings) {
      if (settings.name == '/') {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const UserListScreen(),
        );
      }
      if (settings.name == '/profile') {
        final args = settings.arguments;
        if (args is User) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => ProfileScreen(user: args),
          );
        }
      }
      return null;
    },
    onUnknownRoute: (settings) => MaterialPageRoute(
      builder: (context) => const Scaffold(
        body: Center(child: Text('Page not found')),
      ),
    ),
  );
}

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: ListView(
        children: [
          for (final user in users)
            ListTile(
              leading: CircleAvatar(child: Text(user.name[0])),
              title: Text(user.name),
              onTap: () =>
                  Navigator.pushNamed(context, '/profile', arguments: user),
            ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user.name}', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text('Age: ${user.age}', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text('City: ${user.city}', style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
