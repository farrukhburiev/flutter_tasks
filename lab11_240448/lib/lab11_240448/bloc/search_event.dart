sealed class SearchEvent {
  const SearchEvent();
}

final class SearchSubmitted extends SearchEvent {
  const SearchSubmitted(this.query);

  final String query;
}

final class SearchCleared extends SearchEvent {
  const SearchCleared();
}
