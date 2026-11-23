import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab4_240448/lab11_240448/data/product_api.dart';

import 'fixture_helper.dart';

void main() {
  test('getProducts returns the page from the fixture', () async {
    late Uri requested;
    final api = ProductApi(
      client: MockClient((request) async {
        requested = request.url;
        return http.Response(pageJson(products: [productJson()], total: 1), 200);
      }),
    );

    final page = await api.getProducts();

    expect(page.products, hasLength(1));
    expect(page.total, 1);
    expect(requested.host, 'dummyjson.com');
    expect(requested.path, '/products');
    expect(requested.queryParameters, {'limit': '20', 'skip': '0'});
  });

  test('getProduct answers 404 with an ApiException', () async {
    final api = ProductApi(
      client: MockClient(
        (_) async => http.Response(jsonEncode({'message': 'not found'}), 404),
      ),
    );

    expect(() => api.getProduct(0), throwsA(isA<ApiException>()));
  });

  test('search sends the query', () async {
    late Uri requested;
    final api = ProductApi(
      client: MockClient((request) async {
        requested = request.url;
        return http.Response(pageJson(products: [], total: 0), 200);
      }),
    );

    final page = await api.search('phone case');

    expect(page.products, isEmpty);
    expect(requested.path, '/products/search');
    expect(requested.queryParameters['q'], 'phone case');
  });

  test('a lost connection becomes an ApiException', () {
    final api = ProductApi(
      client: MockClient((_) async => throw http.ClientException('Connection failed')),
    );

    expect(() => api.getProducts(), throwsA(isA<ApiException>()));
  });

  test('invalid JSON becomes an ApiException', () {
    final api = ProductApi(client: MockClient((_) async => http.Response('not json', 200)));

    expect(() => api.getProducts(), throwsA(isA<ApiException>()));
  });

  test('a slow server becomes an ApiException', () {
    final api = ProductApi(
      timeout: const Duration(milliseconds: 50),
      client: MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return http.Response(pageJson(products: [], total: 0), 200);
      }),
    );

    expect(() => api.getProducts(), throwsA(isA<ApiException>()));
  });
}
