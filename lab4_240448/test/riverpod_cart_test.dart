import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab4_240448/lab9_240448/main.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutApi extends Mock implements CheckoutApi {}

void main() {
  setUpAll(() => registerFallbackValue(0.0));

  test('two keyboards with SAVE10 total 88.2', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final cart = container.read(cartProvider.notifier);

    cart.add(catalog.first);
    cart.add(catalog.first);
    cart.applyCoupon('SAVE10');

    expect(container.read(cartProvider).total, closeTo(88.2, 0.001));
  });

  test('failed checkout sets failure and keeps lines', () async {
    final api = MockCheckoutApi();
    when(() => api.submit(any())).thenAnswer(
      (_) => Future<String>.error(const CheckoutException('Card declined')),
    );
    final container = ProviderContainer(overrides: [
      checkoutApiProvider.overrideWith((ref) => api),
    ]);
    addTearDown(container.dispose);
    final cart = container.read(cartProvider.notifier);

    cart.add(catalog.first);
    await cart.checkout();

    final state = container.read(cartProvider);
    expect(state.status, CheckoutStatus.failure);
    expect(state.checkoutError, 'Card declined');
    expect(state.lines, isNotEmpty);
  });
}
