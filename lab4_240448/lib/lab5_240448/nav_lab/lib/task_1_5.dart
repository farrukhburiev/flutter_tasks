import 'package:flutter/material.dart';

Widget buildApp() => const MaterialApp(home: RootScreen());

class BackOrExitButton extends StatelessWidget {
  const BackOrExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return ElevatedButton(
      onPressed: canPop ? () => Navigator.pop(context) : null,
      child: Text(canPop ? 'Back' : 'Nothing to go back to'),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Root')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BackOrExitButton(),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PushedScreen()),
              ),
              child: const Text('Open pushed screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class PushedScreen extends StatelessWidget {
  const PushedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pushed')),
      body: const Center(child: BackOrExitButton()),
    );
  }
}
