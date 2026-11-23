import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab4_240448/lab11_240448/bloc/search_bloc.dart';
import 'package:lab4_240448/lab11_240448/bloc/search_event.dart';
import 'package:lab4_240448/lab11_240448/bloc/search_state.dart';
import 'package:lab4_240448/lab11_240448/data/product_api.dart';

import 'fixture_helper.dart';

ProductApi searchApi() => ProductApi(
      client: MockClient((request) async {
        final query = request.url.queryParameters['q'] ?? '';
        if (query == 'phone') {
          await Future<void>.delayed(const Duration(milliseconds: 150));
        }
        if (query == 'nothing') {
          return http.Response(pageJson(products: [], total: 0), 200);
        }
        if (query == 'broken') {
          return http.Response('{"message":"boom"}', 500);
        }
        return http.Response(
          pageJson(products: [productJson(title: query)], total: 1, limit: 30),
          200,
        );
      }),
    );

void main() {
  blocTest<SearchBloc, SearchState>(
    'search emits loading then results',
    build: () => SearchBloc(searchApi()),
    act: (bloc) => bloc.add(const SearchSubmitted('laptop')),
    expect: () => [isA<SearchLoading>(), isA<SearchResults>()],
  );

  blocTest<SearchBloc, SearchState>(
    'a blank query emits only idle',
    build: () => SearchBloc(searchApi()),
    act: (bloc) => bloc.add(const SearchSubmitted('   ')),
    expect: () => [isA<SearchIdle>()],
  );

  blocTest<SearchBloc, SearchState>(
    'no matches emits loading then empty',
    build: () => SearchBloc(searchApi()),
    act: (bloc) => bloc.add(const SearchSubmitted('nothing')),
    expect: () => [
      isA<SearchLoading>(),
      isA<SearchEmpty>().having((s) => s.query, 'query', 'nothing'),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'a server error emits loading then error',
    build: () => SearchBloc(searchApi()),
    act: (bloc) => bloc.add(const SearchSubmitted('broken')),
    expect: () => [isA<SearchLoading>(), isA<SearchError>()],
  );

  blocTest<SearchBloc, SearchState>(
    'restartable cancels the older search',
    build: () => SearchBloc(searchApi()),
    act: (bloc) => bloc
      ..add(const SearchSubmitted('phone'))
      ..add(const SearchSubmitted('laptop')),
    wait: const Duration(milliseconds: 400),
    expect: () => [
      isA<SearchLoading>(),
      isA<SearchResults>().having((s) => s.products.single.title, 'title', 'laptop'),
    ],
  );
}
