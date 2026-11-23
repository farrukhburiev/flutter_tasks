import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageSourceException implements Exception {
  const ImageSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ImageSources {
  ImageSources({http.Client? client}) : _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 15);

  final ImagePicker _picker = ImagePicker();
  final http.Client _client;

  /// Returns null when the user cancels.
  Future<Uint8List?> fromCamera() => _pick(ImageSource.camera, 'camera');

  /// Returns null when the user cancels.
  Future<Uint8List?> fromGallery() => _pick(ImageSource.gallery, 'gallery');

  Future<Uint8List?> _pick(ImageSource source, String name) async {
    try {
      final file = await _picker.pickImage(source: source, maxWidth: 1024);
      return file == null ? null : await file.readAsBytes();
    } on Object catch (e) {
      throw ImageSourceException(
        'Could not open the $name. Check the app permissions.\n$e',
      );
    }
  }

  Future<Uint8List> fromUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    final isWeb = uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'http' || uri.scheme == 'https');
    if (!isWeb) {
      throw const ImageSourceException(
        'Enter a valid image address starting with http:// or https://',
      );
    }

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const ImageSourceException(
        'The download timed out. Check the address and your connection.',
      );
    } on SocketException {
      throw const ImageSourceException('No network connection.');
    } on http.ClientException {
      throw const ImageSourceException('The address could not be reached.');
    } on IOException {
      throw const ImageSourceException(
        'A secure connection to that address could not be made.',
      );
    }

    if (response.statusCode != 200) {
      throw ImageSourceException(
        'The server answered with status ${response.statusCode} instead of 200.',
      );
    }

    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.startsWith('image/')) {
      throw ImageSourceException(
        'That address is not a picture (content-type: '
        '${contentType.isEmpty ? 'missing' : contentType}).',
      );
    }

    return response.bodyBytes;
  }

  void close() => _client.close();
}
