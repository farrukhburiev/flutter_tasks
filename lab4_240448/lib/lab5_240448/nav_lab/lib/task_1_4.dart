import 'package:flutter/material.dart';

Widget buildApp() => const MaterialApp(home: StepScreen(step: 1));

class StepScreen extends StatelessWidget {
  final int step;
  const StepScreen({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final isLast = step == 4;
    return Scaffold(
      appBar: AppBar(title: Text('Step $step')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            if (isLast) {
              Navigator.popUntil(context, (route) => route.isFirst);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StepScreen(step: step + 1),
                ),
              );
            }
          },
          child: Text(isLast ? 'Finish' : 'Next'),
        ),
      ),
    );
  }
}
