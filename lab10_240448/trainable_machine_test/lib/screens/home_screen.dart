import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../services/classifier.dart';
import '../services/image_sources.dart';
import '../theme/app_theme.dart';
import '../widgets/record_tile.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _busy = false;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openResult(ClassificationRecord record) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ResultScreen(record: record)),
    );
  }

  Future<void> _run(
    Future<Uint8List?> Function() fetch,
    ImageOrigin origin,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await fetch();
      if (bytes == null || !mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final record = widget.controller.classify(bytes, origin);
      if (!mounted) return;
      await _openResult(record);
    } on ImageSourceException catch (e) {
      _showError(e.message);
    } on ClassifierException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Uint8List?> _downloadImage() async {
    final url = await showDialog<String>(
      context: context,
      builder: (_) => const _UrlDialog(),
    );
    if (url == null) return null;
    return widget.controller.sources.fromUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sources = widget.controller.sources;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: LinearProgressIndicator(),
              ),
            Text(
              'What would you like to classify?',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionCard(
              icon: Icons.photo_camera_outlined,
              title: 'Take a photo',
              subtitle: 'Use the phone camera',
              onTap: _busy
                  ? null
                  : () => _run(sources.fromCamera, ImageOrigin.camera),
            ),
            _ActionCard(
              icon: Icons.photo_library_outlined,
              title: 'Choose from gallery',
              subtitle: 'Pick a picture you already have',
              onTap: _busy
                  ? null
                  : () => _run(sources.fromGallery, ImageOrigin.gallery),
            ),
            _ActionCard(
              icon: Icons.cloud_download_outlined,
              title: 'Download an image',
              subtitle: 'Enter an image address',
              onTap: _busy
                  ? null
                  : () => _run(_downloadImage, ImageOrigin.download),
            ),
            ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) {
                final latest = widget.controller.latest;
                if (latest == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Text('Latest result', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    RecordTile(
                      record: latest,
                      onTap: () => _openResult(latest),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        enabled: onTap != null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _UrlDialog extends StatefulWidget {
  const _UrlDialog();

  @override
  State<_UrlDialog> createState() => _UrlDialogState();
}

class _UrlDialogState extends State<_UrlDialog> {
  final TextEditingController _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Download an image'),
      content: TextField(
        controller: _text,
        autofocus: true,
        keyboardType: TextInputType.url,
        decoration: const InputDecoration(
          labelText: 'Image address',
          hintText: 'https://example.com/photo.jpg',
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () => Navigator.of(context).pop(_text.text),
          child: const Text('Download'),
        ),
      ],
    );
  }
}
