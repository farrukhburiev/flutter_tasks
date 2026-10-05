import 'package:flutter/material.dart';

import 'task1_selection_controls.dart' show SelectionControlsScreen;
import 'task2_input_fields.dart' show InputFieldsScreen;
import 'task3_button.dart' show ButtonsScreen;
import 'task4_indicator_feedback.dart' show IndicatorsFeedbackScreen;
import 'task5_dialogs_modal.dart' show DialogsModalsScreen;
import 'task6_slider_pickers.dart' show SlidersPickersScreen;
import 'task7_scrollable_lists.dart' show ScrollableListScreen;
import 'task8_grid_display.dart' show GridDisplayScreen;
import 'task9_navigation.dart' show NavigationHubScreen;


void main() => runApp(const LabApp());

class LabApp extends StatelessWidget {
  const LabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 4: Flutter Mobile Widgets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class _Entry {
  const _Entry(this.title, this.subtitle, this.builder);

  final String title;
  final String subtitle;
  final WidgetBuilder builder;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<_Entry> _entries = [
    _Entry('Task 1', 'Checkbox & Switch', (_) => const SelectionControlsScreen()),
    _Entry('Task 2', 'TextField & TextFormField', (_) => const InputFieldsScreen()),
    _Entry('Task 3', 'FloatingActionButton & ElevatedButton', (_) => const ButtonsScreen()),
    _Entry('Task 4', 'CircularProgressIndicator & SnackBar', (_) => const IndicatorsFeedbackScreen()),
    _Entry('Task 5', 'AlertDialog & showModalBottomSheet', (_) => const DialogsModalsScreen()),
    _Entry('Task 6', 'Slider & showDatePicker', (_) => const SlidersPickersScreen()),
    _Entry('Task 7', 'ListView.builder & Dismissible', (_) => const ScrollableListScreen()),
    _Entry('Task 8', 'GridView.count', (_) => const GridDisplayScreen()),
    _Entry('Task 9', 'BottomNavigationBar & TabBar', (_) => const NavigationHubScreen()),
   
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 4: Flutter Mobile Widgets')),
      body: ListView.separated(
        itemCount: _entries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = _entries[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(entry.title),
            subtitle: Text(entry.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: entry.builder),
            ),
          );
        },
      ),
    );
  }
}