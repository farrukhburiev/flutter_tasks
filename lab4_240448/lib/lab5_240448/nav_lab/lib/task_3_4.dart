import 'package:flutter/material.dart';

Widget buildApp() => const MaterialApp(home: HomeScreen());

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color _color = Colors.grey;

  Future<void> _chooseColor() async {
    final chosen = await Navigator.push<Color>(
      context,
      MaterialPageRoute(builder: (_) => const ColorPickerScreen()),
    );
    if (!mounted || chosen == null) return;
    setState(() => _color = chosen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Current colour')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 150, height: 150, color: _color),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _chooseColor,
              child: const Text('Choose colour'),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorPickerScreen extends StatelessWidget {
  const ColorPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const options = [Colors.red, Colors.green, Colors.blue];
    return Scaffold(
      appBar: AppBar(title: const Text('Pick a colour')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final color in options)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 48),
                  ),
                  onPressed: () => Navigator.pop(context, color),
                  child: const Text('Select'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
