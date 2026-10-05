import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DialogsModalsScreen(),
    ),
  );
}

class DialogsModalsScreen extends StatefulWidget {
  const DialogsModalsScreen({super.key});

  @override
  State<DialogsModalsScreen> createState() => _DialogsModalsScreenState();
}

class _DialogsModalsScreenState extends State<DialogsModalsScreen> {
  bool _itemExists = true;

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _itemExists = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted')),
      );
    }
  }

  void _showShareSheet() {
    const options = <MapEntry<String, IconData>>[
      MapEntry('Copy link', Icons.link),
      MapEntry('Send by email', Icons.email_outlined),
      MapEntry('Send by message', Icons.message_outlined),
      MapEntry('More options', Icons.more_horiz),
    ];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              ListTile(
                leading: Icon(option.value),
                title: Text(option.key),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${option.key} selected')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialogs & Modals')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(_itemExists ? 'Sample item' : 'Item deleted'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _itemExists ? _confirmDelete : null,
              ),
            ),
          ),
          if (!_itemExists)
            TextButton(
              onPressed: () => setState(() => _itemExists = true),
              child: const Text('Restore item'),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showShareSheet,
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }
}