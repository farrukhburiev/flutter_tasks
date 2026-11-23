import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../theme/app_theme.dart';

class RecordTile extends StatelessWidget {
  const RecordTile({super.key, required this.record, required this.onTap});

  final ClassificationRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: Image.memory(
            record.imageBytes,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            cacheWidth: 112,
          ),
        ),
        title: Text(record.top.label, style: theme.textTheme.titleMedium),
        subtitle: Text(
          '${formatPercent(record.top.confidence)} · ${record.origin.label}',
          style: theme.textTheme.bodyMedium,
        ),
        trailing: Icon(record.origin.icon, color: theme.colorScheme.primary),
      ),
    );
  }
}
