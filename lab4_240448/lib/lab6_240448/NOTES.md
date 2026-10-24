# Lab 6 — Real-Time Data Ticker with AsyncValue

## Part 2 — inline questions

1. **Why is the feed behind its own Provider?** It makes the feed injectable. Tests and demos can override it (`TickFeed(symbols: const [])`, `TickFeed(failAfter: 5)`) without touching `tickerProvider`, and `tickerProvider` rebuilds automatically when the feed's configuration (`failAfterProvider`) changes. Constructing the feed inside `tickerProvider` would hard-wire it.
2. **What does `autoDispose` do when the user navigates away mid-stream?** When the last listener goes away, the provider is disposed: the stream subscription is cancelled, the `async*` generator stops, no more ticks are produced, and nothing leaks. Coming back creates a fresh provider that starts at `AsyncLoading` again.
3. **What does `tickerProvider` hold during the 800 ms delay?** `AsyncLoading<List<Tick>>`. `hasValue` is `false` because nothing has been emitted yet.

## Part 3 — exercises

**3.3** With the `AsyncLoading()` arm commented out, `flutter analyze` reports (`non_exhaustive_switch_expression`):

> The type 'AsyncValue<List<Tick>>' is not exhaustively matched by the switch cases since it doesn't match 'AsyncLoading<List<Tick>>()'. Try adding a wildcard pattern or cases that match 'AsyncLoading<List<Tick>>()'.

**3.4** Arms are tested top to bottom and the first match wins. `AsyncData(:final value)` matches every data state, so if it came first the `value: []` and `value: [final only]` arms would be unreachable (the analyzer flags them as dead/unreachable cases).

## Part 4 — exercises

**4.3 refresh vs invalidate.** Both keep the previous rows visible while reloading, because the new loading state carries the previous value (`hasValue` stays `true`, `isLoading` is `true`). The difference is the return value: `ref.invalidate` returns `void` and marks the provider stale, so it rebuilds lazily, while `ref.refresh(tickerProvider.future)` rebuilds immediately and returns a `Future<List<Tick>>` that completes when the new first value (or error) arrives. That future is awaitable, so `RefreshIndicator` keeps its spinner exactly until the reload finishes.

**4.4 reconnect vs first load.** The refresh arm `AsyncValue(:final value?, isLoading: true)` sits above `AsyncData` and `AsyncLoading`, so after a retry the rows stay on screen with a thin `LinearProgressIndicator`; the full-screen spinner only appears on cold start (no previous value).
`isRefreshing` is a loading flag on an existing `AsyncData`/`AsyncError` (manual refresh/invalidate), whereas `isReloading` means the value is an `AsyncLoading` that carries previous data (typically a rebuild caused by a changed dependency such as `failAfterProvider`).

## Checkpoint questions

1. **Sealed subtypes:** `AsyncData`, `AsyncLoading`, `AsyncError`. A switch expression that misses one gets the `non_exhaustive_switch_expression` error shown in 3.3.
2. **`AsyncError.value`:** non-null when data had been emitted before the error (stream error after ticks, or refresh after data); `null` when the error happens before any data (cold start).
3. **`ref.refresh(provider)`** invalidates and immediately rebuilds, returning the new `AsyncValue`; **`ref.refresh(provider.future)`** does the same but returns a `Future` of the new value you can await; **`ref.invalidate(provider)`** only marks it stale (returns `void`) and the rebuild happens lazily on the next read or frame.
4. **Ordering:** `AsyncData` with `isLoading: true` (a refresh) also matches `AsyncData(:final value)`. If the general arm came first it would swallow the refreshing state and the progress bar would never show. Specific arms must sit above general ones.
5. **Switch vs `.when`:** switch expressions give compile-time exhaustiveness, let you match on state and content together (guards, `value?`, list patterns, `isLoading: true`) and need no callbacks. `.when` is still convenient for a quick, flat three-callback widget that is happy with its default refresh/reload skipping behavior.

## Stretch goals implemented

1. **Per-symbol providers:** `tickProvider` (a `Provider.autoDispose.family<Tick?, String>` using `tickerProvider.select`) with `LiveTickRow` watching only its own symbol.
2. **Flash on change:** `LiveTickRow` uses `ref.listen` to flash green/red for 300 ms.
4. **`AsyncValue.guard`:** `balanceProvider` and `BalanceDialog` (wallet icon in the AppBar; fails randomly to show the error path).
