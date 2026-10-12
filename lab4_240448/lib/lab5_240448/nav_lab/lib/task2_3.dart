import 'package:flutter/material.dart';

class AppRoutes {
  static const home = '/';
  static const settings = '/settings';
}

Widget buildApp() {
  return MaterialApp(
    initialRoute: AppRoutes.home,
    routes: {
      AppRoutes.home: (context) => const HomeScreen(),
      AppRoutes.settings: (context) => const SettingsScreen(),
    },
    onUnknownRoute: (settings) => MaterialPageRoute(
      builder: (context) => const NotFoundScreen(),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
              child: const Text('Settings'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/does-not-exist'),
              child: const Text('Open missing page'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings')),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 12),
            const Text('Page not found', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
