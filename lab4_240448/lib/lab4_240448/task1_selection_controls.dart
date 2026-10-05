import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const SelectionControlsScreen(),
    ),
  );
}

class SelectionControlsScreen extends StatefulWidget {
  const SelectionControlsScreen({super.key});

  @override
  State<SelectionControlsScreen> createState() => _SelectionControlsScreenState();
}

class _SelectionControlsScreenState extends State<SelectionControlsScreen> {
  bool _darkMode = false;
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: _darkMode ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle the screen theme'),
              secondary: Icon(_darkMode ? Icons.dark_mode : Icons.light_mode),
              value: _darkMode,
              onChanged: (value) => setState(() => _darkMode = value),
            ),
            CheckboxListTile(
              title: const Text('Agree to Terms'),
              controlAffinity: ListTileControlAffinity.leading,
              value: _agreed,
              onChanged: (value) => setState(() => _agreed = value ?? false),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _agreed
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Terms accepted')),
                      )
                  : null,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}