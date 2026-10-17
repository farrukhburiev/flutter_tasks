import 'package:flutter/material.dart';

class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const profile = '/profile';
}

Widget buildApp() {
  return MaterialApp(
    initialRoute: AppRoutes.login,
    routes: {
      AppRoutes.login: (context) => const LoginScreen(),
      AppRoutes.home: (context) => const HomeScreen(),
      AppRoutes.profile: (context) => const ProfileScreen(),
    },
  );
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.home),
          child: const Text('Sign in'),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          child: const Text('Open profile'),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          ),
          child: const Text('Log out'),
        ),
      ),
    );
  }
}
