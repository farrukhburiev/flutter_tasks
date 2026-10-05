import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const SlidersPickersScreen(),
    ),
  );
}

class SlidersPickersScreen extends StatefulWidget {
  const SlidersPickersScreen({super.key});

  @override
  State<SlidersPickersScreen> createState() => _SlidersPickersScreenState();
}

class _SlidersPickersScreenState extends State<SlidersPickersScreen> {
  double _volume = 50;
  DateTime? _selectedDate;

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  IconData get _volumeIcon {
    if (_volume == 0) return Icons.volume_off;
    if (_volume < 50) return Icons.volume_down;
    return Icons.volume_up;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sliders & Pickers')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Icon(_volumeIcon, size: 32),
              const SizedBox(width: 12),
              Text(
                'Volume: ${_volume.round()}%',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          Slider(
            value: _volume,
            min: 0,
            max: 100,
            divisions: 100,
            label: '${_volume.round()}%',
            onChanged: (value) => setState(() => _volume = value),
          ),
          const Divider(height: 48),
          ElevatedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: const Text('Select Date'),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedDate == null
                ? 'No date selected'
                : 'Selected date: ${_formatDate(_selectedDate!)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}