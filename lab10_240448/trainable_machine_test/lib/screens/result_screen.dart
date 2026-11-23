import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/probability_row.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.record});

  final ClassificationRecord record;

  @override
  Widget build(BuildContext context) {
    final imageHeight = MediaQuery.sizeOf(context).height * 0.5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Chip(
              avatar: Icon(record.origin.icon, size: 18),
              label: Text(record.origin.label),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Center(
              child: SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  child: Image.memory(record.imageBytes, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < record.predictions.length; i++)
              ProbabilityRow(
                prediction: record.predictions[i],
                highlighted: i == 0,
              ),
          ],
        ),
      ),
    );
  }
}
