import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../services/classifier.dart';
import '../theme/app_theme.dart';

class ModelScreen extends StatelessWidget {
  const ModelScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classifier = controller.classifier;
    const credit = DesignCredit.current;

    return Scaffold(
      appBar: AppBar(title: const Text('Model')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Card(
              child: Column(
                children: [
                  _InfoTile(label: 'Classes', value: '${classifier.classCount}'),
                  _InfoTile(
                    label: 'Input size',
                    value: '${Classifier.inputSize} × ${Classifier.inputSize}',
                  ),
                  _InfoTile(label: 'Model file', value: classifier.modelFileName),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Labels', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final label in classifier.labels)
                  Chip(label: Text(label)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Design credit', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  _InfoTile(label: 'Design', value: credit.name),
                  _InfoTile(label: 'Author', value: credit.author),
                  _InfoTile(label: 'Link', value: credit.link),
                  _InfoTile(label: 'Licence', value: credit.licence),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(label, style: theme.textTheme.bodyMedium),
      subtitle: Text(value, style: theme.textTheme.titleMedium),
    );
  }
}
