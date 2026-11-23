import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab4_240448/lab11_240448/cubit/details_cubit.dart';
import 'package:lab4_240448/lab11_240448/cubit/products_cubit.dart';
import 'package:lab4_240448/lab11_240448/data/product_api.dart';

import 'fixture_helper.dart';

ProductApi okApi({int total = 1, void Function()? onRequest}) => ProductApi(
      client: MockClient((request) async {
        onRequest?.call();
        final skip = int.parse(request.url.queryParameters['skip'] ?? '0');
        return http.Response(
          pageJson(products: [productJson(id: skip + 1)], total: total, skip: skip),
          200,
        );
      }),
    );

ProductApi failingApi() => ProductApi(
      client: MockClient((_) async => http.Response('{"message":"boom"}', 500)),
    );

void main() {
  blocTest<ProductsCubit, ProductsState>(
    'load success emits loading then loaded',
    build: () => ProductsCubit(okApi()),
    act: (cubit) => cubit.load(),
    expect: () => [isA<ProductsLoading>(), isA<ProductsLoaded>()],
  );

  blocTest<ProductsCubit, ProductsState>(
    'load failure emits loading then error',
    build: () => ProductsCubit(failingApi()),
    act: (cubit) => cubit.load(),
    expect: () => [isA<ProductsLoading>(), isA<ProductsError>()],
  );

  blocTest<ProductsCubit, ProductsState>(
    'loadMore appends the next page',
    build: () => ProductsCubit(okApi(total: 2)),
    act: (cubit) async {
      await cubit.load();
      await cubit.loadMore();
    },
    skip: 2,
    expect: () => [
      isA<ProductsLoaded>().having((s) => s.isLoadingMore, 'isLoadingMore', true),
      isA<ProductsLoaded>()
          .having((s) => s.products.length, 'length', 2)
          .having((s) => s.hasMore, 'hasMore', false),
    ],
  );

  test('a second loadMore while loading sends no second request', () async {
    var requests = 0;
    final cubit = ProductsCubit(okApi(total: 3, onRequest: () => requests++));
    await cubit.load();

    final first = cubit.loadMore();
    final second = cubit.loadMore();
    await Future.wait([first, second]);

    expect(requests, 2);
    expect((cubit.state as ProductsLoaded).products, hasLength(2));
    await cubit.close();
  });

  blocTest<DetailsCubit, DetailsState>(
    'details success emits loading then loaded',
    build: () => DetailsCubit(
      ProductApi(
        client: MockClient((_) async => http.Response(jsonEncode(productJson()), 200)),
      ),
      1,
    ),
    act: (cubit) => cubit.load(),
    expect: () => [isA<DetailsLoading>(), isA<DetailsLoaded>()],
  );

  blocTest<DetailsCubit, DetailsState>(
    'details failure emits loading then error',
    build: () => DetailsCubit(failingApi(), 1),
    act: (cubit) => cubit.load(),
    expect: () => [isA<DetailsLoading>(), isA<DetailsError>()],
  );
}
