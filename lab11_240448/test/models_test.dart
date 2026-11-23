import 'package:flutter_test/flutter_test.dart';
import 'package:lab4_240448/lab11_240448/models/product.dart';
import 'package:lab4_240448/lab11_240448/models/product_page.dart';

import 'fixture_helper.dart';

void main() {
  test('parses the saved fixture', () {
    final product = Product.fromJson(loadProductJson());

    expect(product.id, 1);
    expect(product.title, 'Essence Mascara Lash Princess');
    expect(product.price, isA<double>());
    expect(product.price, 9.99);
    expect(product.brand, 'Essence');
    expect(product.tags, ['beauty', 'mascara']);
    expect(product.dimensions.width, 15.14);
    expect(product.reviews, hasLength(3));
    expect(product.reviews.first.reviewerName, 'Eleanor Collins');
    expect(product.reviews.first.date.year, 2025);
    expect(product.images, hasLength(1));
  });

  test('missing brand is null and missing tags become an empty list', () {
    final product = Product.fromJson({
      'id': 2,
      'title': 'No extras',
      'price': 10,
      'rating': 4,
      'thumbnail': 'https://example.com/t.webp',
      'dimensions': {'width': 1, 'height': 2, 'depth': 3},
    });

    expect(product.brand, isNull);
    expect(product.tags, isEmpty);
    expect(product.reviews, isEmpty);
    expect(product.price, 10.0);
    expect(product.dimensions.depth, 3.0);
  });

  test('integer numbers from the server become doubles', () {
    final json = productJson()..['price'] = 10;
    expect(Product.fromJson(json).price, isA<double>());
  });

  test('ProductPage reuses Product.fromJson', () {
    final page = ProductPage.fromJson({
      'products': [loadProductJson()],
      'total': 194,
      'skip': 0,
      'limit': 20,
    });

    expect(page.products.single.title, 'Essence Mascara Lash Princess');
    expect(page.total, 194);
    expect(page.skip, 0);
    expect(page.limit, 20);
  });
}
