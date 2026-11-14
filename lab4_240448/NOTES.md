# Lab 9 — One Cart, Four Ways

## Part 1 — inline questions

1. **Why is `CartLine` immutable with `copyWith`?** Every style decides "did the state change?" by comparing the new value with the old one (Riverpod and Cubit/Bloc use `==`, `setState` simply rebuilds). Undo also stores old snapshots, which only stay valid if nobody mutates them afterwards. **Only `setState` would still "work" with mutation**, because it rebuilds no matter what. That is the trap: the code looks correct, then fails after a migration, because Riverpod/Cubit/Bloc see the same instance (or an equal one) and silently skip the notification, and the undo history ends up pointing at the mutated object.
2. **Why does `CartBody` take callbacks?** It stays style-independent: the same widget serves all four pages, can be tested without any provider or bloc in the tree, and cannot accidentally depend on one state-management library.

## Part 2 — setState

- **T3 — why storing `total` is a bug waiting to happen:** a stored `total` is a second source of truth. Every mutation (add, qty change, coupon, undo, checkout reset) must remember to recompute it; one missed path and the screen shows a total that disagrees with the lines. `copyWith` would also carry a stale total forward and `==` would compare redundant data. A getter is always correct by construction.
- **T4 — what happens without `if (!mounted) return;`:** if the user leaves the page during the 1.5 s checkout, `setState` runs on a disposed `State` and throws "setState() called after dispose()", and the SnackBar/banner code would use a dead `BuildContext`.
- **T6:** most of the widget test is finding and driving widgets (`find.text`, `tap`, `enterText`, `pump`); the cart logic itself is a single assertion.
- **After T4, how would an order-history page read the cart?** It can't: the state is a private field of one `State` object. You would have to lift the state to a common ancestor and pass it down (or add an InheritedWidget), i.e. move to a real state holder.
- **Where does `_history` live, and hot restart vs hot reload?** It is a field of the `State` object. Hot reload keeps the `State` object, so the history survives; hot restart rebuilds the whole app, so the cart and history are lost.

## Part 3 — Riverpod

- **T2:** with a plain class (no `==`), `state = state.copyWith(coupon: code)` creates a new instance that is never equal to the old one, so listeners are notified even when nothing changed. With `==`/`hashCode` (via `Equatable`) an unchanged result is skipped.
- **T3:** `RiverpodSummary` prints `RiverpodSummary rebuilt` when a quantity or valid coupon changes, but not when typing in the coupon field (the text lives in a local controller) or when an invalid coupon only changes `couponError`.
- **T4 — why no `mounted` check:** the notifier lives in the `ProviderContainer`, not in the widget, so leaving the page does not affect it; the result is simply written to `cartProvider`. The page's `ref.listen` is cancelled automatically when the widget is disposed. (With an `autoDispose` provider and no listener left, writing `state` after the await would be unsafe and would need a `ref.mounted` guard.)
- **T5:** `canUndoProvider` must `ref.watch(cartProvider)` because `_history` is a plain field and not observable: the watch makes the provider recompute whenever the cart state changes. After making `cartProvider` `autoDispose`, popping the page and returning gives an empty cart and empty history: with no listener the provider is disposed and `build()` runs again with a fresh notifier.
- **`ref.read` places:** (1) `ref.read(cartProvider.notifier)` in the page's `build` to get method handles, (2) `ref.read(cartProvider)` inside the `ref.listen` callback (a one-off lookup in a callback), (3) `ref.read(checkoutApiProvider)` in `checkout()` (inject a service, no subscription), (4) `ref.read(cartProvider.notifier)` in `canUndoProvider` to read the getter.
- **`ref.watch` places:** (1) `ref.watch(cartProvider)` in the page to rebuild lines/coupon error/busy state, (2) `ref.watch(canUndoProvider)` for the Undo button, (3) `ref.watch(cartProvider.select(...))` in `RiverpodSummary` to rebuild only on summary changes, (4) `ref.watch(cartProvider)` in `canUndoProvider` so it recomputes.
- **Why the summary card rebuilds less than in the setState version:** with `setState` the whole page rebuilds and creates a new `SummaryCard` on every change; with `select` on a record, `RiverpodSummary` rebuilds only when item count, subtotal, discount or total actually change.

## Part 4 — Cubit

- **T2:** applying the same coupon twice gives `onChange` only once in the `BlocObserver` log; the second `emit` equals the current state and is dropped.
- **T4:** `emit` after `close()` throws a `StateError`, hence `if (isClosed) return;` after the await.
- **T5:** a `canUndo` getter on the cubit is not observable: `BlocBuilder` only rebuilds on emitted states. The fix is to put `history` into `CartState` and derive `canUndo` from it.
- **What would break if `BlocProvider` were inside `CartBody`?** Only descendants of `CartBody` could find the cubit. The AppBar Undo button and the `BlocListener` (siblings/ancestors) would throw `ProviderNotFoundException`, and `CartBody` would be tied to one cubit, losing its role as a dumb shared widget.
- **Riverpod equivalents:** `BlocProvider` → `NotifierProvider` + `ProviderScope`; `BlocBuilder` → `ref.watch` in a `ConsumerWidget`/`Consumer`; `BlocListener` → `ref.listen`; `context.read` → `ref.read`; `buildWhen` → `ref.watch(provider.select(...))`.

## Part 5 — Bloc

- **T2:** the observer's `onTransition` log shows `currentState --Event--> nextState`, so you also see which named event caused the change; the Cubit's `onChange` log only shows the states.
- **T4:** with `droppable()` three quick taps on Checkout produce one `submitting` state and one API call; the other two events are discarded while the first is running. A Cubit without a guard would start three overlapping API calls and emit repeated states; it needs a manual `if (state.isSubmitting) return;`. Inside the handler, `emit.isDone` is checked after the await.
- **T5 — undoable events (the `switch` in `_onMutation`):** `CartProductAdded`, `CartProductRemoved`, `CartQtyChanged` and `CartCouponApplied` push to history; `CartCheckoutRequested` and `CartUndone` do not. A successful checkout clears the cart and its history.
- **When is the event layer worth it?** Worth it for checkout: named event, per-event concurrency (`droppable`), traceable transitions. Pure overhead for add/remove/quantity: each event maps one-to-one to a trivial method with no async behaviour.
- **Which style gives declarative "drop duplicate taps"?** Only Bloc (`transformer: droppable()`). In the others: `setState`, Riverpod and Cubit guard on `status == submitting` (plus a disabled button); in `setState` one could also use a boolean flag.

## Checkpoint questions

1. **Where state lives / when it dies:**
   - setState: in the `State` object; dies when the page is popped.
   - Riverpod: in the `ProviderContainer` (root `ProviderScope`); lives with the app (non-autoDispose), or dies when the last listener goes if `autoDispose`.
   - Cubit: in the cubit instance owned by `BlocProvider`; closed when the provider leaves the tree.
   - Bloc: same as Cubit, in the bloc instance owned by `BlocProvider`.
2. **Single public mutation API:** Notifier: its public methods (assigning `state` is only possible from inside the notifier); Cubit: its public methods that call `emit`; Bloc: `add(event)`. `setState` has none: only code inside the `State` class can mutate, and nothing outside can.
3. **Mapping:** `ref.watch` ↔ `BlocBuilder` (and `select` ↔ `BlocSelector`/`buildWhen`); `ref.read` ↔ `context.read`; `ref.listen` ↔ `BlocListener`. `setState` is the mutate-and-rebuild step itself (the equivalent of assigning `state`/`emit` combined with rebuilding the owner); there is no subscription step.
4. **Why skip when equal, and what must `CartState` do:** it avoids pointless rebuilds and effects when nothing changed. `CartState` needs (1) `==`/`hashCode` based on all fields (here via `Equatable` props), and (2) value-comparable, immutable nested data (`CartLine`, `Product`, new lists instead of in-place mutation) so that equal content compares equal and changes always produce a different value.
5. **Guards after the await:** setState → `mounted` (state belongs to a widget that can be disposed); Riverpod → none (the notifier outlives the widget); Cubit → `isClosed` (emit after close throws); Bloc → `emit.isDone` (the handler's emitter is finished once the bloc is closed or the handler is done).

## Comparison table

Lines are those of the corresponding section of `main.dart` (state holder + page, all of T1–T5, blank lines included); the shared model, API and dumb UI add about 400 lines used by all four. Files are as in the lab's suggested layout.

| Style | Lines T1–T5 (holder + page) | Test lines | Files | Strength | Weakness |
|---|---|---|---|---|---|
| setState | 82 | 21 | 1 | Fewest concepts, no dependency | State is trapped in one widget; test is mostly widget plumbing |
| Riverpod | 108 | 42 | 2 | Global access, `select`, tests without widgets | Must understand `watch`/`read`/`listen` rules |
| Cubit | 103 | 63 | 2 | Simple methods, `blocTest` checks emitted sequence | Provider scoping; getters are not observable |
| Bloc | 172 | 73 | 3 | Traceable events, declarative concurrency (`droppable`) | Most boilerplate |

## Not done

Stretch goals 1–4 were not implemented. Git tags, the screen recording and the live demonstration to the instructor still have to be done by you.
