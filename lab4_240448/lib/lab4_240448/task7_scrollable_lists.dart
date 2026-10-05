import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const ScrollableListScreen(),
    ),
  );
}

class ScrollableListScreen extends StatefulWidget {
  const ScrollableListScreen({super.key});

  @override
  State<ScrollableListScreen> createState() => _ScrollableListScreenState();
}

class _ScrollableListScreenState extends State<ScrollableListScreen> {
  late final List<String> _items = List<String>.generate(20, (i) => 'Item ${i + 1}');

  void _removeItem(int index) {
    final removed = _items[index];
    setState(() => _items.removeAt(index));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$removed dismissed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (!mounted) return;
              setState(() => _items.insert(index.clamp(0, _items.length), removed));
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scrollable List')),
      body: _items.isEmpty
          ? const Center(child: Text('No items left'))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Dismissible(
                  key: ValueKey<String>(item),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _removeItem(index),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(item),
                    subtitle: const Text('Swipe to dismiss'),
                  ),
                );
              },
            ),
    );
  }
}