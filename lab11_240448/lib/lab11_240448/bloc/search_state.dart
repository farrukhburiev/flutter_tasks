import '../models/product.dart';

sealed class SearchState {
  const SearchState();
}

final class SearchIdle extends SearchState {
  const SearchIdle();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchEmpty extends SearchState {
  const SearchEmpty(this.query);

  final String query;
}

final class SearchResults extends SearchState {
  const SearchResults(this.products);

  final List<Product> products;
}

final class SearchError extends SearchState {
  const SearchError(this.message);

  final String message;
}
