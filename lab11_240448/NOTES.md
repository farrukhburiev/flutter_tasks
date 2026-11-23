# Lab 11 — A REST API Client with Cubit and Bloc

## Part 1 — Setup and your first request

**Q1. Field types in `product.json`**

| Kind | Field |
|---|---|
| number | `price` (9.99), also `rating`, `stock`, and `weight` (4, which Dart decodes as an `int`) |
| list of strings | `tags` (`["beauty", "mascara"]`) |
| nested object | `dimensions` (`width`, `height`, `depth`) |
| list of objects | `reviews` (each has `rating`, `comment`, `date`, `reviewerName`, `reviewerEmail`) |

**Q2. `/products/0`:** the server answers with status `404` and a small JSON body with a `message` saying the product was not found (the exact text is printed by `bin/peek.dart`). A 404 still has a body, so the API class checks the status code before it parses the body.

## Part 2 — Models from JSON

**Q1. `json['price'] as double` when the server sends `10`:** Dart decodes `10` as an `int`, and the cast `as double` fails at **run time** with a `TypeError` ("type 'int' is not a subtype of type 'double'"). The compiler cannot catch it because `json` is `Map<String, dynamic>`, so the values have type `dynamic`. The fix is `(json['price'] as num).toDouble()`.

**Q2. Why test `fromJson` with a saved file?** The test is fast, free, works offline and always gets the same data, so it can only fail when the code is wrong. A live request depends on the network and on a server whose data can change.

**Decision for missing `tags` (T6):** a missing `tags` key becomes an empty list (`const []`), so the UI never needs a null check. A missing `brand` is `null` (nullable field). Missing `description`, `images` and `reviews` also fall back to `''` / empty lists. `id`, `title`, `price`, `rating`, `thumbnail` and `dimensions` are required: if one is missing, parsing fails and the API turns the error into an `ApiException`.

## Part 3 — The API service

- `ProductApi` has three endpoints (`getProducts`, `getProduct`, `search`) and a single `_get` method with the only `jsonDecode` call.
- `_get` checks the status code first, uses `.timeout(Duration(seconds: 10))`, and turns every failure into an `ApiException` with a readable sentence: non-200 status, `TimeoutException`, `http.ClientException` (no connection), `FormatException` (not JSON) and `TypeError` (JSON of the wrong shape).
- The client is injected (`ProductApi(client: ...)`), so tests use `MockClient`.

## Part 4 — The Cubit for the list

**Q1. `?delay=3000` and leaving the screen without `isClosed`:** `BlocProvider` closes the cubit when the screen is popped. When the response arrives 3 seconds later, `emit` on a closed cubit throws a `StateError` ("Cannot emit new states after calling close"), which ends as an unhandled asynchronous exception. `if (isClosed) return;` prevents it. (To try it, change `ProductApi()` to `ProductApi(delayMs: 3000)` in `main.dart`.)

**Q2. Why `isA<…>()` and not `ProductsLoaded([...])`?** The state classes do not override `==`, so two `ProductsLoaded` objects are equal only if they are the same object; a freshly built expected state would never match. To compare by value, add `==` and `hashCode` (or extend `Equatable`) to the state classes and to `Product`, `Dimensions` and `Review`, so that the lists inside compare by value too.

**Load more:** `loadMore()` ignores calls when the state is not `ProductsLoaded`, when there is nothing more to load, or when `isLoadingMore` is already `true`; the flag is set by an emitted state before the request starts, so a second tap cannot send a second request.

## Part 5 — The Bloc for search

**T15 — proving the cancel** (with `ProductApi(delayMs: 3000)`): search `phone`, then immediately `laptop`. The spinner stays for about 3 seconds and then **only the laptop results appear**; the phone results never show up, even though the phone request is still in flight. *(Write down what you see on your own screen.)*

**Design note:** the bloc handles both events with one handler (`on<SearchEvent>` + `restartable()`) and an exhaustive `switch` over the sealed events. That way `SearchCleared` also cancels a search that is still running; with two separate handlers a late search result could overwrite the cleared screen.

## Checkpoint questions

1. **One product from response to screen**
   1. HTTP answer: `String` body in `http.Response` — `data/product_api.dart` (`_get`)
   2. `jsonDecode` gives `Map<String, dynamic>` — same place (`data/product_api.dart`)
   3. `ProductPage.fromJson` — `models/product_page.dart`, which calls `Product.fromJson` — `models/product.dart` (with `Dimensions` and `Review` for nested objects, `models/review.dart`)
   4. `ProductApi.getProducts` returns a typed `ProductPage` to `ProductsCubit.load` — `cubit/products_cubit.dart`
   5. The cubit emits `ProductsLoaded(List<Product>)` (the state)
   6. `BlocBuilder` + `switch` in `screens/products_screen.dart` builds `ProductTile` — `widgets/product_tile.dart`, which draws `Text` / `Image.network`.
2. **Errors of `getProducts` and what the user sees:** timeout, no connection, status other than 200 (404, 500…), invalid JSON and JSON of the wrong shape all become an `ApiException` with a readable sentence. The cubit emits `ProductsError(message)` and the screen shows the message with a **Retry** button. If a list is already on screen (refresh or load more fails), the list stays and the message appears under it.
3. **Cubit or Bloc?** The product list uses a Cubit: the actions are plain methods (`load`, `refresh`, `loadMore`) and nothing needs an event trace or a special transformer. The search uses a Bloc: it is driven by user events, and `restartable()` (an event transformer, which a Cubit does not have) cancels the old search when a new one starts.
4. **`restartable()`:** when a new event arrives while the previous handler is still running, the old handler is cancelled and its late `emit` is ignored. With the default transformer both handlers run at the same time; if the older request (`phone`) answers last, its results replace the newer ones, so the user would see results for `phone` while the field says `laptop`.
5. **Why widgets must not call `http.get` or read a `Map`:**
   - `build` runs many times, so a request inside it would be repeated, would have no loading or error handling and could not be tested without a network.
   - A `Map` is untyped: a wrong key or a wrong cast only fails at run time, on the screen. Models check the data once, in one place, and the compiler checks everything that uses them.
   - Keeping the network and JSON in one layer means a change of the server (address, field names) touches one file, not every widget.
