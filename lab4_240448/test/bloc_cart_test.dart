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

  blocTest<CartBloc, CartState>(
    'emits one state per event',
    build: () => CartBloc(MockCheckoutApi()),
    act: (b) => b
      ..add(CartProductAdded(keyboard))
      ..add(CartProductAdded(keyboard))
      ..add(const CartCouponApplied('SAVE10')),
    expect: () => [s1, s2, s3],
  );

  final failingApi = MockCheckoutApi();
  blocTest<CartBloc, CartState>(
    'failed checkout emits submitting then failure',
    setUp: () {
      when(() => failingApi.submit(any())).thenAnswer(
        (_) => Future<String>.error(const CheckoutException('Card declined')),
      );
    },
    build: () => CartBloc(failingApi),
    act: (b) => b
      ..add(CartProductAdded(keyboard))
      ..add(const CartCheckoutRequested()),
    wait: const Duration(milliseconds: 50),
    skip: 1,
    expect: () => [
      isA<CartState>().having((s) => s.status, 'status', CheckoutStatus.submitting),
      isA<CartState>()
          .having((s) => s.status, 'status', CheckoutStatus.failure)
          .having((s) => s.lines.length, 'lines', 1),
    ],
  );

  final slowApi = MockCheckoutApi();
  blocTest<CartBloc, CartState>(
    'droppable drops the second checkout request',
    setUp: () {
      when(() => slowApi.submit(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return 'ORD-1';
      });
    },
    build: () => CartBloc(slowApi),
    act: (b) => b
      ..add(CartProductAdded(keyboard))
      ..add(const CartCheckoutRequested())
      ..add(const CartCheckoutRequested()),
    wait: const Duration(milliseconds: 100),
    skip: 1,
    expect: () => [
      isA<CartState>().having((s) => s.status, 'status', CheckoutStatus.submitting),
      isA<CartState>().having((s) => s.status, 'status', CheckoutStatus.success),
    ],
    verify: (_) {
      verify(() => slowApi.submit(any())).called(1);
    },
  );
}
