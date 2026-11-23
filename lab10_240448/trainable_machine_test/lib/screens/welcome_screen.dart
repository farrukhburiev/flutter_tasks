import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../theme/app_theme.dart';
import 'app_shell.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.loading});

  final Future<AppController> loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<AppController>(
          future: loading,
          builder: (context, snapshot) {
            final controller = snapshot.data;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.center_focus_strong_outlined,
                        size: 72,
                        color: scheme.primary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Teach It, Ship It',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Point your phone at an object and a model you trained '
                        'yourself names it, fully offline.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (snapshot.hasError)
                        _ErrorState(message: snapshot.error.toString())
                      else if (controller == null)
                        const _LoadingState()
                      else
                        _ClassChips(labels: controller.classifier.labels),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: controller == null
                            ? null
                            : () => Navigator.of(context).pushReplacement(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        AppShell(controller: controller),
                                  ),
                                ),
                        child: const Text('Get started'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: AppSpacing.md),
        Text('Loading model...', style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
        const SizedBox(height: AppSpacing.sm),
        Text('The model could not be loaded', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ClassChips extends StatelessWidget {
  const _ClassChips({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('It recognises', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [for (final label in labels) Chip(label: Text(label))],
        ),
      ],
    );
  }
}
