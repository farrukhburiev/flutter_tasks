# Lab 11 — step-by-step guide

Everything is already written. Your job is to put the files in the right places, run, commit with the tags and record the video. Do it in this order.

## 0. What you got

```
lab11/
├── GUIDE.md                      (this file, do not commit)
├── NOTES.md                      → project root
├── bin/peek.dart                 → bin/peek.dart
├── test/
│   ├── fixtures/product.json     → test/fixtures/product.json
│   ├── fixture_helper.dart       → test/
│   ├── models_test.dart          → test/
│   ├── api_test.dart             → test/
│   ├── products_cubit_test.dart  → test/
│   └── search_bloc_test.dart     → test/
└── lib/lab11_240448/             → lib/lab11_240448/   (whole folder)
    ├── main.dart
    ├── models/    product.dart, review.dart, product_page.dart
    ├── data/      product_api.dart
    ├── cubit/     products_cubit.dart, details_cubit.dart
    ├── bloc/      search_event.dart, search_state.dart, search_bloc.dart
    ├── screens/   products_screen.dart, details_screen.dart, search_screen.dart
    └── widgets/   product_tile.dart
```

The tests import `package:lab11240448/lab11_240448/...`. That matches your project `lab4_240448`. If your project has another name, or you made a fresh `api_catalog` project, replace `lab11240448/lab11_240448` in the test imports with your package name (`name:` in `pubspec.yaml`) and the folder path.

## 1. Part 1 — setup (tag `p1-setup`)

Open a terminal in the **project root** (the folder with `pubspec.yaml`, here `lab4_240448`), not inside `lib`:

```
flutter pub add http flutter_bloc bloc_concurrency
flutter pub add --dev bloc_test
```

1. Copy `bin/peek.dart` into `bin/` (create the folder) and `product.json` into `test/fixtures/`.
2. Open `android/app/src/main/AndroidManifest.xml` and add this line inside `<manifest>`, above `<application>`:
   `<uses-permission android:name="android.permission.INTERNET"/>`
3. Run `dart run bin/peek.dart`. You should see `200`, `Essence Mascara Lash Princess`, `_Map<String, dynamic>`, then `404` and the not-found message.
4. Copy `NOTES.md` to the project root.

```
git add pubspec.yaml pubspec.lock bin test/fixtures android NOTES.md
git commit -m "Part 1: setup"
git tag p1-setup
```

## 2. Part 2 — models (tag `p2-models`)

1. Copy `lib/lab11_240448/models/` and `test/fixture_helper.dart`, `test/models_test.dart`.
2. `flutter test test/models_test.dart` → 4 tests pass.

```
git add lib/lab11_240448/models test/fixture_helper.dart test/models_test.dart
git commit -m "Part 2: models"
git tag p2-models
```

## 3. Part 3 — API (tag `p3-api`)

1. Copy `lib/lab11_240448/data/` and `test/api_test.dart`.
2. `flutter test test/api_test.dart` → 6 tests pass (no internet needed).

```
git add lib/lab11_240448/data test/api_test.dart
git commit -m "Part 3: api"
git tag p3-api
```

## 4. Part 4 — Cubit and screens (tag `p4-cubit`)

1. Copy `cubit/`, `widgets/`, `screens/` (all three files) and `main.dart`, plus `test/products_cubit_test.dart`.
2. `flutter test test/products_cubit_test.dart` → 6 tests pass.
3. Run the app: `flutter run -t lib/lab11_240448/main.dart` (in VS Code, open `lib/lab11_240448/main.dart` and press Run there).
4. Check: list loads, **Load more** shows `(20 of 194)`, pull down refreshes, tapping a row opens details with reviews.
5. Turn on airplane mode, restart the app: you get the error message with **Retry**. Turn it off and tap Retry.

Note: `products_screen.dart` imports `search_screen.dart`, which needs the `bloc/` folder, so copy `bloc/` now too if you want this commit to compile. If you prefer to keep strictly to parts, an intermediate commit may show analyzer errors; the tag only has to exist, and the final state must be clean.

```
git add lib/lab11_240448/cubit lib/lab11_240448/widgets lib/lab11_240448/screens/products_screen.dart lib/lab11_240448/screens/details_screen.dart lib/lab11_240448/main.dart test/products_cubit_test.dart
git commit -m "Part 4: cubit, list and details"
git tag p4-cubit
```

## 5. Part 5 — Bloc search (tag `p5-bloc`)

1. Copy `bloc/`, `screens/search_screen.dart`, `test/search_bloc_test.dart`.
2. `flutter test` → everything passes (4 + 6 + 6 + 5 = 21 tests, no network).
3. **T15, prove the cancel:** in `main.dart` change `ProductApi()` to `ProductApi(delayMs: 3000)`, run the app, open search, submit `phone` and immediately `laptop`. After about 3 seconds only laptop results appear. Write what you saw in `NOTES.md` (T15 paragraph). Then change it back to `ProductApi()`.
4. Optional: with `delayMs: 3000`, open the list and leave the screen quickly to see why `isClosed` matters (Part 4 question).

```
git add lib/lab11_240448/bloc lib/lab11_240448/screens/search_screen.dart test/search_bloc_test.dart NOTES.md
git commit -m "Part 5: bloc search"
git tag p5-bloc
git push
git push --tags
```

## 6. Final checks before the demo

```
flutter analyze
flutter test
```

- `flutter analyze` should report no issues. If it shows something, send me the text.
- `test/fixtures/product.json` must be committed.
- No generated files and no converter sites were used: models are hand-written (rule 5).

## 7. Screen recording (under 60 s)

Record in this order: app start (spinner) → list → tap **Load more** → turn on airplane mode and show the error → **Retry** after turning it off → open a product with reviews → go back → open search and search `phone`.

## 8. Demo to the instructor

Be ready to explain from raw JSON to screen (checkpoint question 1 in `NOTES.md`), why `isClosed` and `emit.isDone` exist, and what `restartable()` does. Both partners must be able to explain any part.

## 9. If something fails

- *"Target of URI doesn't exist: package:..."*: the package name in the test imports is wrong (see section 0), or `flutter pub add` was not run in the project root.
- *Images do not show*: the thumbnail then shows an icon (by design); check the internet permission and connection.
- *`flutter test` cannot find `test/fixtures/product.json`*: run the command from the project root.
