import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/product_page.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProductApi {
  ProductApi({
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
    this.delayMs,
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;
  final int? delayMs;

  static const _host = 'dummyjson.com';

  Map<String, String> _query(Map<String, String> params) => {
        ...params,
        if (delayMs != null) 'delay': '$delayMs',
      };

  Future<ProductPage> getProducts({int limit = 20, int skip = 0}) => _get(
        Uri.https(_host, '/products', _query({'limit': '$limit', 'skip': '$skip'})),
        ProductPage.fromJson,
      );

  Future<Product> getProduct(int id) => _get(
        Uri.https(_host, '/products/$id'),
        Product.fromJson,
      );

  Future<ProductPage> search(String query) => _get(
        Uri.https(_host, '/products/search', _query({'q': query})),
        ProductPage.fromJson,
      );

  void close() => _client.close();

  Future<T> _get<T>(Uri uri, T Function(Map<String, dynamic>) parse) async {
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        throw ApiException(_describe(response.statusCode));
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object');
      }
      return parse(decoded);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('The server took too long to answer. Please try again.');
    } on http.ClientException {
      throw const ApiException('No connection. Check your internet and try again.');
    } on FormatException {
      throw const ApiException('The server sent a response the app cannot read.');
    } on TypeError {
      throw const ApiException('The server sent data in an unexpected format.');
    }
  }

  String _describe(int code) {
    if (code == 404) return 'We could not find that item (error 404).';
    if (code >= 500) return 'The server has a problem (error $code). Try again later.';
    return 'The server answered with error $code.';
  }
}
