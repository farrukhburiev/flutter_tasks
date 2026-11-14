import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab4_240448/lab9_240448/main.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutApi extends Mock implements CheckoutApi {}

void main() {
  setUpAll(() => registerFallbackValue(0.0));

  final keyboard = catalog.first;
  const empty = CartState();
  final s1 = empty.pushed(empty.added(keyboard));
  final s2 = s1.pushed(s1.added(keyboard));
  final s3 = s2.pushed(s2.couponApplied('SAVE10'));

  blocTest<CartCubit, CartState>(
    'emits one state per mutation',
    build: () => CartCubit(MockCheckoutApi()),
    act: (c) {
      c.add(keyboard);
      c.add(keyboard);
      c.applyCoupon('SAVE10');
    },
    expect: () => [s1, s2, s3],
  );

  blocTest<CartCubit, CartState>(
    'drops a duplicate coupon emit',
    build: () => CartCubit(MockCheckoutApi()),
    act: (c) {
      c.add(keyboard);
      c.applyCoupon('SAVE10');
      c.applyCoupon('SAVE10');
    },
    expect: () => [
      isA<CartState>().having((s) => s.itemCount, 'itemCount', 1),
      isA<CartState>().having((s) => s.coupon, 'coupon', 'SAVE10'),
    ],
  );

  final api = MockCheckoutApi();
  blocTest<CartCubit, CartState>(
    'failed checkout emits submitting then failure',
    setUp: () {
      when(() => api.submit(any())).thenAnswer(
        (_) => Future<String>.error(const CheckoutException('Card declined')),
      );
    },
    build: () => CartCubit(api),
    act: (c) async {
      c.add(keyboard);
      await c.checkout();
    },
    skip: 1,
    expect: () => [
      isA<CartState>().having((s) => s.status, 'status', CheckoutStatus.submitting),
      isA<CartState>()
          .having((s) => s.status, 'status', CheckoutStatus.failure)
          .having((s) => s.lines.length, 'lines', 1),
    ],
  );
}
