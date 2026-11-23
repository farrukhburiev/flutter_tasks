import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'labels.dart';

class Prediction {
  const Prediction(this.label, this.confidence);

  final String label;
  final double confidence; // 0.0 to 1.0
}

class ClassifierException implements Exception {
  const ClassifierException(this.message);

  final String message;

  @override
  String toString() => message;
}

class Classifier {
  Classifier._(this._interpreter, this.labels);

  static const modelAsset = 'assets/model/model_unquant.tflite';
  static const labelsAsset = 'assets/model/labels.txt';
  static const inputSize = 224;

  final Interpreter _interpreter;
  final List<String> labels;
  bool _closed = false;

  int get classCount => labels.length;

  String get modelFileName => modelAsset.split('/').last;

  static Future<Classifier> load() async {
    final Interpreter interpreter;
    try {
      interpreter = await Interpreter.fromAsset(modelAsset);
    } on Object catch (e) {
      throw ClassifierException(
        'Could not load the model.\n'
        'Expected file: $modelAsset\n'
        'Check that the file exists and that assets/model/ is declared in pubspec.yaml.\n'
        'Details: $e',
      );
    }

    final String raw;
    try {
      raw = await rootBundle.loadString(labelsAsset);
    } on Object catch (e) {
      interpreter.close();
      throw ClassifierException(
        'Could not load the labels.\n'
        'Expected file: $labelsAsset\n'
        'Details: $e',
      );
    }

    final labels = parseLabels(raw);
    final outputClasses = interpreter.getOutputTensor(0).shape.last;
    if (labels.isEmpty || labels.length != outputClasses) {
      interpreter.close();
      throw ClassifierException(
        'labels.txt has ${labels.length} labels but the model outputs '
        '$outputClasses classes. Export model and labels together.',
      );
    }

    return Classifier._(interpreter, labels);
  }

  List<Prediction> classify(Uint8List bytes) {
    if (_closed) {
      throw const ClassifierException('The classifier has been closed.');
    }

    img.Image? decoded;
    try {
      decoded = img.decodeImage(bytes);
    } on Object {
      decoded = null;
    }
    if (decoded == null) {
      throw const ClassifierException('This file is not a readable image.');
    }

    final square = img.copyResizeCropSquare(
      img.bakeOrientation(decoded),
      size: inputSize,
    );

    final input = [
      List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final p = square.getPixel(x, y);
          return [p.r / 127.5 - 1, p.g / 127.5 - 1, p.b / 127.5 - 1];
        }),
      ),
    ];
    final output = [List<double>.filled(labels.length, 0)];

    try {
      _interpreter.run(input, output);
    } on Object catch (e) {
      throw ClassifierException('The model failed to process the image.\n$e');
    }

    return [
      for (var i = 0; i < labels.length; i++)
        Prediction(labels[i], output.first[i]),
    ]..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  void close() {
    if (_closed) return;
    _closed = true;
    _interpreter.close();
  }
}
