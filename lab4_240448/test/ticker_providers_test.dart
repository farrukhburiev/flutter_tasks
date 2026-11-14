import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_ticker/main.dart';

void main() {
  test('starts loading, then emits data', () async {
    final container = ProviderContainer(overrides: [
      tickFeedProvider.overrideWith((ref) => TickFeed(symbols: const ['BTC'])),
    ]);
    addTearDown(container.dispose);
    final sub = container.listen(tickerProvider, (_, __) {});

    expect(sub.read(), isA<AsyncLoading<Object?>>());
    expect(sub.read().hasValue, isFalse);

    final first = await container.read(tickerProvider.future);
    expect(first.single.symbol, 'BTC');
    expect(sub.read().hasValue, isTrue);
    sub.close();
  });

  test('surfaces FeedException as AsyncError with previous value', () async {
    final container = ProviderContainer(overrides: [
      tickFeedProvider.overrideWith(
        (ref) => TickFeed(symbols: const ['BTC'], failAfter: 1),
      ),
    ]);
    addTearDown(container.dispose);
    final sub = container.listen(tickerProvider, (_, __) {});

    await container.read(tickerProvider.future);
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final state = sub.read();
    expect(state, isA<AsyncError<Object?>>());
    expect(state.hasValue, isTrue, reason: 'previous ticks are kept');
    expect(state.error, isA<FeedException>());
    sub.close();
  });
}
