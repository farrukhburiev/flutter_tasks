import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const GridDisplayScreen(),
    ),
  );
}

class GridDisplayScreen extends StatelessWidget {
  const GridDisplayScreen({super.key});

  static const int _imageCount = 12;

  static String _imageUrl(int index) =>
      'https://picsum.photos/seed/lab4_$index/600/600';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Gallery')),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        padding: const EdgeInsets.all(12),
        children: List<Widget>.generate(_imageCount, (index) {
          final url = _imageUrl(index);
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ImagePreviewScreen(url: url, tag: 'image_$index'),
              ),
            ),
            child: Hero(
              tag: 'image_$index',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _NetworkTile(url: url),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NetworkTile extends StatelessWidget {
  const _NetworkTile({required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[300],
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, size: 40),
      ),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  const ImagePreviewScreen({super.key, required this.url, required this.tag});

  final String url;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Preview'),
      ),
      body: SizedBox.expand(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Hero(
            tag: tag,
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: _NetworkTile(url: url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}