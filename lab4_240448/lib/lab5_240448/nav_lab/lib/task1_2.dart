import 'package:flutter/material.dart';

Widget buildApp() => const MaterialApp(home: ScreenA());

class ScreenA extends StatelessWidget {
  const ScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen A'),
        backgroundColor: Colors.red.shade300,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScreenB()),
          ),
          child: const Text('Next'),
        ),
      ),
    );
  }
}

class ScreenB extends StatelessWidget {
  const ScreenB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen B'),
        backgroundColor: Colors.green.shade300,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScreenC()),
          ),
          child: const Text('Next'),
        ),
      ),
    );
  }
}

class ScreenC extends StatelessWidget {
  const ScreenC({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen C'),
        backgroundColor: Colors.blue.shade300,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back'),
        ),
      ),
    );
  }
}
