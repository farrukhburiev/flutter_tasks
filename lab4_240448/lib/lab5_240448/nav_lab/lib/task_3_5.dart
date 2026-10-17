import 'package:flutter/material.dart';

Widget buildApp() => const MaterialApp(home: HomeScreen());

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _value = 0;

  Future<void> _edit() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(initial: _value)),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() => _value = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_value', style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _edit, child: const Text('Edit')),
          ],
        ),
      ),
    );
  }
}

class EditorScreen extends StatefulWidget {
  final int initial;
  const EditorScreen({super.key, required this.initial});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late int _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editor')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: () => setState(() => _value--),
                  icon: const Icon(Icons.remove),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text('$_value', style: const TextStyle(fontSize: 48)),
                ),
                IconButton.filled(
                  onPressed: () => setState(() => _value++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _value),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
