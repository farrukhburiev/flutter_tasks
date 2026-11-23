import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'classifier.dart';
import 'image_sources.dart';

enum ImageOrigin {
  camera('Camera', Icons.photo_camera_outlined),
  gallery('Gallery', Icons.photo_library_outlined),
  download('Download', Icons.cloud_download_outlined);

  const ImageOrigin(this.label, this.icon);

  final String label;
  final IconData icon;
}

String formatPercent(double confidence) =>
    '${(confidence * 100).toStringAsFixed(1)} %';

class ClassificationRecord {
  const ClassificationRecord({
    required this.imageBytes,
    required this.predictions,
    required this.origin,
    required this.time,
  });

  final Uint8List imageBytes;
  final List<Prediction> predictions;
  final ImageOrigin origin;
  final DateTime time;

  Prediction get top => predictions.first;
}

class AppController extends ChangeNotifier {
  AppController({required this.classifier, required this.sources});

  final Classifier classifier;
  final ImageSources sources;
  final List<ClassificationRecord> _history = [];

  /// Newest first.
  List<ClassificationRecord> get history => List.unmodifiable(_history);

  ClassificationRecord? get latest => _history.isEmpty ? null : _history.first;

  static Future<AppController> create() async {
    final classifier = await Classifier.load();
    return AppController(classifier: classifier, sources: ImageSources());
  }

  ClassificationRecord classify(Uint8List bytes, ImageOrigin origin) {
    final record = ClassificationRecord(
      imageBytes: bytes,
      predictions: classifier.classify(bytes),
      origin: origin,
      time: DateTime.now(),
    );
    _history.insert(0, record);
    notifyListeners();
    return record;
  }

  void close() {
    classifier.close();
    sources.close();
  }
}
