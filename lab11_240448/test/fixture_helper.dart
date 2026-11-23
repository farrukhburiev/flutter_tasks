import 'dart:convert';
import 'dart:io';

Map<String, dynamic> loadProductJson() =>
    jsonDecode(File('test/fixtures/product.json').readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> productJson({int id = 1, String? title}) => {
      ...loadProductJson(),
      'id': id,
      if (title != null) 'title': title,
    };

String pageJson({
  required List<Map<String, dynamic>> products,
  required int total,
  int skip = 0,
  int limit = 20,
}) =>
    jsonEncode({'products': products, 'total': total, 'skip': skip, 'limit': limit});
