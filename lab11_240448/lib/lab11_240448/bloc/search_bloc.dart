import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_api.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._api) : super(const SearchIdle()) {
    on<SearchEvent>(_onEvent, transformer: restartable());
  }

  final ProductApi _api;

  Future<void> _onEvent(SearchEvent event, Emitter<SearchState> emit) async {
    switch (event) {
      case SearchCleared():
        emit(const SearchIdle());
      case SearchSubmitted(:final query):
        await _search(query.trim(), emit);
    }
  }

  Future<void> _search(String query, Emitter<SearchState> emit) async {
    if (query.isEmpty) {
      emit(const SearchIdle());
      return;
    }
    emit(const SearchLoading());
    try {
      final page = await _api.search(query);
      if (emit.isDone) return;
      emit(page.products.isEmpty ? SearchEmpty(query) : SearchResults(page.products));
    } on ApiException catch (e) {
      if (emit.isDone) return;
      emit(SearchError(e.message));
    }
  }
}
