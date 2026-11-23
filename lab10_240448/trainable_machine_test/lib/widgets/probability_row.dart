import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../services/classifier.dart';
import '../theme/app_theme.dart';

class ProbabilityRow extends StatelessWidget {
  const ProbabilityRow({
    super.key,
    required this.prediction,
    this.highlighted = false,
  });

  final Prediction prediction;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style =
        highlighted ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              prediction.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: LinearProgressIndicator(
                value: prediction.confidence.clamp(0.0, 1.0).toDouble(),
                minHeight: highlighted ? 12 : 8,
                color: highlighted ? scheme.primary : scheme.outline,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 68,
            child: Text(
              formatPercent(prediction.confidence),
              textAlign: TextAlign.end,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
