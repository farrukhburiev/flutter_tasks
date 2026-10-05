import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const IndicatorsFeedbackScreen(),
    ),
  );
}

class IndicatorsFeedbackScreen extends StatefulWidget {
  const IndicatorsFeedbackScreen({super.key});

  @override
  State<IndicatorsFeedbackScreen> createState() => _IndicatorsFeedbackScreenState();
}

class _IndicatorsFeedbackScreenState extends State<IndicatorsFeedbackScreen> {
  bool _loading = false;
  String _status = 'Tap the button to start';

  Future<void> _startOperation() async {
    setState(() {
      _loading = true;
      _status = 'Working...';
    });

    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    setState(() {
      _loading = false;
      _status = 'Operation completed';
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Operation completed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (!mounted) return;
              setState(() => _status = 'Operation undone');
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Indicators & Feedback')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_status),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _startOperation,
                    child: const Text('Start Operation'),
                  ),
                ],
              ),
      ),
    );
  }
}