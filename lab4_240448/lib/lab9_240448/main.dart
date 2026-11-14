import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  Bloc.observer = CartObserver();
  runApp(const ProviderScope(child: CartApp()));
}

class CartApp extends StatelessWidget {
  const CartApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Cart four ways',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const HomePage(),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _open(BuildContext context, Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
    if (context.mounted) ScaffoldMessenger.of(context).clearMaterialBanners();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('One cart, four ways')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              FilledButton(
                onPressed: () => _open(context, const SetStateCartPage()),
                child: const Text('setState'),
              ),
              FilledButton(
                onPressed: () => _open(context, const RiverpodCartPage()),
                child: const Text('Riverpod'),
              ),
              FilledButton(
                onPressed: () => _open(context, const CubitCartPage()),
                child: const Text('Cubit'),
              ),
              FilledButton(
                onPressed: () => _open(context, const BlocCartPage()),
                child: const Text('Bloc'),
              ),
            ],
          ),
        ),
      );
}

// --- shared model ----------------------------------------------------------

const validCoupon = 'SAVE10';

class Product extends Equatable {
  const Product({required this.id, required this.name, required this.price});

  final String id;
  final String name;
  final double price;

  @override
  List<Object?> get props => [id, name, price];
}

const catalog = [
  Product(id: 'p1', name: 'Keyboard', price: 49),
  Product(id: 'p2', name: 'Mouse', price: 25),
  Product(id: 'p3', name: 'Monitor', price: 199),
];

class CartLine extends Equatable {
  const CartLine({required this.product, required this.qty});

  final Product product;
  final int qty;

  double get subtotal => product.price * qty;

  CartLine copyWith({int? qty}) => CartLine(product: product, qty: qty ?? this.qty);

  @override
  List<Object?> get props => [product, qty];
}

extension CartLines on List<CartLine> {
  List<CartLine> withProduct(Product p) {
    final i = indexWhere((l) => l.product.id == p.id);
    if (i == -1) return [...this, CartLine(product: p, qty: 1)];
    return [for (final l in this) l.product.id == p.id ? l.copyWith(qty: l.qty + 1) : l];
  }

  List<CartLine> without(String productId) =>
      [for (final l in this) if (l.product.id != productId) l];

  List<CartLine> changeQty(String productId, int delta) => [
        for (final l in this)
          if (l.product.id != productId)
            l
          else if (l.qty + delta > 0)
            l.copyWith(qty: l.qty + delta),
      ];

  double get subtotal => fold<double>(0, (s, l) => s + l.subtotal);

  int get itemCount => fold<int>(0, (s, l) => s + l.qty);
}

enum CheckoutStatus { idle, submitting, success, failure }

class CartState extends Equatable {
  const CartState({
    this.lines = const [],
    this.coupon,
    this.couponError,
    this.status = CheckoutStatus.idle,
    this.orderId,
    this.checkoutError,
    this.history = const [],
  });

  final List<CartLine> lines;
  final String? coupon;
  final String? couponError;
  final CheckoutStatus status;
  final String? orderId;
  final String? checkoutError;
  final List<CartState> history;

  int get itemCount => lines.itemCount;
  double get subtotal => lines.subtotal;
  double get discount => coupon == validCoupon ? subtotal * 0.1 : 0;
  double get total => subtotal - discount;
  bool get isSubmitting => status == CheckoutStatus.submitting;
  bool get canUndo => history.isNotEmpty;

  CartState copyWith({
    List<CartLine>? lines,
    String? coupon,
    bool clearCoupon = false,
    String? couponError,
    bool clearCouponError = false,
    CheckoutStatus? status,
    String? orderId,
    bool clearOrderId = false,
    String? checkoutError,
    bool clearCheckoutError = false,
    List<CartState>? history,
  }) =>
      CartState(
        lines: lines ?? this.lines,
        coupon: clearCoupon ? null : (coupon ?? this.coupon),
        couponError: clearCouponError ? null : (couponError ?? this.couponError),
        status: status ?? this.status,
        orderId: clearOrderId ? null : (orderId ?? this.orderId),
        checkoutError: clearCheckoutError ? null : (checkoutError ?? this.checkoutError),
        history: history ?? this.history,
      );

  @override
  List<Object?> get props =>
      [lines, coupon, couponError, status, orderId, checkoutError, history];
}

extension CartTransitions on CartState {
  CartState added(Product p) => copyWith(lines: lines.withProduct(p));

  CartState removed(String productId) => copyWith(lines: lines.without(productId));

  CartState qtyChanged(String productId, int delta) =>
      copyWith(lines: lines.changeQty(productId, delta));

  CartState couponApplied(String code) {
    final normalized = code.trim().toUpperCase();
    if (normalized == validCoupon) {
      return copyWith(coupon: normalized, clearCouponError: true);
    }
    return copyWith(clearCoupon: true, couponError: 'Invalid coupon code');
  }

  CartState checkoutStarted() => copyWith(
        status: CheckoutStatus.submitting,
        clearCheckoutError: true,
        clearOrderId: true,
      );

  CartState checkoutSucceeded(String orderId) =>
      CartState(status: CheckoutStatus.success, orderId: orderId);

  CartState checkoutFailed(String message) =>
      copyWith(status: CheckoutStatus.failure, checkoutError: message);
}

extension CartHistory on CartState {
  CartState pushed(CartState next) =>
      next.copyWith(history: [...history, copyWith(history: const [])]);

  CartState undone() {
    if (history.isEmpty) return this;
    return history.last.copyWith(history: history.sublist(0, history.length - 1));
  }
}

// --- checkout service ------------------------------------------------------

class CheckoutException implements Exception {
  const CheckoutException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CheckoutApi {
  Future<String> submit(double total) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (total > 500) throw const CheckoutException('Card declined');
    return 'ORD-${DateTime.now().millisecondsSinceEpoch % 10000}';
  }
}

// --- shared dumb UI --------------------------------------------------------

void handleCheckoutStatus(BuildContext context, CartState state) {
  final messenger = ScaffoldMessenger.of(context);
  switch (state.status) {
    case CheckoutStatus.idle:
      break;
    case CheckoutStatus.submitting:
      messenger.hideCurrentMaterialBanner();
    case CheckoutStatus.success:
      messenger.showSnackBar(SnackBar(content: Text('Order ${state.orderId} placed')));
    case CheckoutStatus.failure:
      messenger
        ..hideCurrentMaterialBanner()
        ..showMaterialBanner(
          MaterialBanner(
            content: Text(state.checkoutError ?? 'Checkout failed'),
            actions: [
              TextButton(
                onPressed: () => messenger.hideCurrentMaterialBanner(),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        );
  }
}

class CartBody extends StatelessWidget {
  const CartBody({
    super.key,
    required this.lines,
    required this.onAdd,
    required this.onQtyChanged,
    required this.couponField,
    required this.summary,
    required this.checkoutButton,
  });

  final List<CartLine> lines;
  final void Function(Product) onAdd;
  final void Function(String productId, int delta) onQtyChanged;
  final Widget couponField;
  final Widget summary;
  final Widget checkoutButton;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: [
                for (final p in catalog)
                  ActionChip(
                    label: Text('${p.name} · ${p.price.toStringAsFixed(0)}'),
                    onPressed: () => onAdd(p),
                  ),
              ],
            ),
          ),
          Expanded(
            child: lines.isEmpty
                ? const Center(child: Text('Cart is empty'))
                : ListView(
                    children: [
                      for (final l in lines)
                        ListTile(
                          key: ValueKey(l.product.id),
                          title: Text(l.product.name),
                          subtitle: Text('${l.product.price.toStringAsFixed(2)} each'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Decrease',
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => onQtyChanged(l.product.id, -1),
                              ),
                              Text('${l.qty}'),
                              IconButton(
                                tooltip: 'Increase',
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => onQtyChanged(l.product.id, 1),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: couponField),
          summary,
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(width: double.infinity, child: checkoutButton),
          ),
        ],
      );
}

class CouponField extends StatefulWidget {
  const CouponField({super.key, required this.onApply, this.error});

  final void Function(String code) onApply;
  final String? error;

  @override
  State<CouponField> createState() => _CouponFieldState();
}

class _CouponFieldState extends State<CouponField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Coupon code',
                isDense: true,
                errorText: widget.error,
              ),
              onSubmitted: widget.onApply,
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: () => widget.onApply(_controller.text),
            child: const Text('Apply'),
          ),
        ],
      );
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.itemCount,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  final int itemCount;
  final double subtotal;
  final double discount;
  final double total;

  Widget _row(String label, String value, {bool bold = false, Key? valueKey}) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, key: valueKey, style: style),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row('Items', '$itemCount'),
              _row('Subtotal', subtotal.toStringAsFixed(2)),
              _row('Discount', discount == 0 ? '0.00' : '-${discount.toStringAsFixed(2)}'),
              _row('Total', total.toStringAsFixed(2), bold: true, valueKey: const ValueKey('total')),
            ],
          ),
        ),
      );
}

class CheckoutButton extends StatelessWidget {
  const CheckoutButton({
    super.key,
    required this.busy,
    required this.enabled,
    required this.onPressed,
  });

  final bool busy;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: busy || !enabled ? null : onPressed,
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Checkout'),
      );
}

class UndoAction extends StatelessWidget {
  const UndoAction({super.key, required this.canUndo, required this.onUndo});

  final bool canUndo;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: 'Undo',
        icon: const Icon(Icons.undo),
        onPressed: canUndo ? onUndo : null,
      );
}

// --- setState --------------------------------------------------------------

class SetStateCartPage extends StatefulWidget {
  const SetStateCartPage({super.key, this.api});

  final CheckoutApi? api;

  @override
  State<SetStateCartPage> createState() => _SetStateCartPageState();
}

class _SetStateCartPageState extends State<SetStateCartPage> {
  CartState _state = const CartState();
  final List<CartState> _history = [];
  late final CheckoutApi _api = widget.api ?? CheckoutApi();

  void _mutate(CartState Function(CartState) change) {
    if (_state.isSubmitting) return;
    final next = change(_state);
    if (next == _state) return;
    setState(() {
      _history.add(_state);
      _state = next;
    });
  }

  void _add(Product p) => _mutate((s) => s.added(p));

  void _changeQty(String id, int delta) => _mutate((s) => s.qtyChanged(id, delta));

  void _applyCoupon(String code) => _mutate((s) => s.couponApplied(code));

  void _undo() {
    if (_history.isEmpty || _state.isSubmitting) return;
    setState(() => _state = _history.removeLast());
  }

  Future<void> _checkout() async {
    if (_state.isSubmitting || _state.lines.isEmpty) return;
    setState(() => _state = _state.checkoutStarted());
    handleCheckoutStatus(context, _state);
    try {
      final orderId = await _api.submit(_state.total);
      if (!mounted) return;
      setState(() {
        _history.clear();
        _state = _state.checkoutSucceeded(orderId);
      });
    } on CheckoutException catch (e) {
      if (!mounted) return;
      setState(() => _state = _state.checkoutFailed(e.message));
    }
    if (!mounted) return;
    handleCheckoutStatus(context, _state);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Cart · setState'),
          actions: [UndoAction(canUndo: _history.isNotEmpty, onUndo: _undo)],
        ),
        body: CartBody(
          lines: _state.lines,
          onAdd: _add,
          onQtyChanged: _changeQty,
          couponField: CouponField(error: _state.couponError, onApply: _applyCoupon),
          summary: SummaryCard(
            itemCount: _state.itemCount,
            subtotal: _state.subtotal,
            discount: _state.discount,
            total: _state.total,
          ),
          checkoutButton: CheckoutButton(
            busy: _state.isSubmitting,
            enabled: _state.lines.isNotEmpty,
            onPressed: _checkout,
          ),
        ),
      );
}

// --- Riverpod --------------------------------------------------------------

final checkoutApiProvider = Provider<CheckoutApi>((ref) => CheckoutApi());

class CartNotifier extends Notifier<CartState> {
  final List<CartState> _history = [];

  @override
  CartState build() {
    _history.clear();
    return const CartState();
  }

  bool get canUndo => _history.isNotEmpty;

  void _mutate(CartState Function(CartState) change) {
    if (state.isSubmitting) return;
    final next = change(state);
    if (next == state) return;
    _history.add(state);
    state = next;
  }

  void add(Product p) => _mutate((s) => s.added(p));

  void remove(String id) => _mutate((s) => s.removed(id));

  void changeQty(String id, int delta) => _mutate((s) => s.qtyChanged(id, delta));

  void applyCoupon(String code) => _mutate((s) => s.couponApplied(code));

  void undo() {
    if (_history.isEmpty || state.isSubmitting) return;
    state = _history.removeLast();
  }

  Future<void> checkout() async {
    if (state.isSubmitting || state.lines.isEmpty) return;
    final api = ref.read(checkoutApiProvider);
    state = state.checkoutStarted();
    try {
      final orderId = await api.submit(state.total);
      _history.clear();
      state = state.checkoutSucceeded(orderId);
    } on CheckoutException catch (e) {
      state = state.checkoutFailed(e.message);
    }
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

final canUndoProvider = Provider<bool>((ref) {
  ref.watch(cartProvider);
  return ref.read(cartProvider.notifier).canUndo;
});

class RiverpodCartPage extends ConsumerWidget {
  const RiverpodCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartProvider);
    final canUndo = ref.watch(canUndoProvider);
    final cart = ref.read(cartProvider.notifier);
    ref.listen<CheckoutStatus>(
      cartProvider.select((s) => s.status),
      (previous, next) => handleCheckoutStatus(context, ref.read(cartProvider)),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart · Riverpod'),
        actions: [UndoAction(canUndo: canUndo, onUndo: cart.undo)],
      ),
      body: CartBody(
        lines: state.lines,
        onAdd: cart.add,
        onQtyChanged: cart.changeQty,
        couponField: CouponField(error: state.couponError, onApply: cart.applyCoupon),
        summary: const RiverpodSummary(),
        checkoutButton: CheckoutButton(
          busy: state.isSubmitting,
          enabled: state.lines.isNotEmpty,
          onPressed: cart.checkout,
        ),
      ),
    );
  }
}

class RiverpodSummary extends ConsumerWidget {
  const RiverpodSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (count, subtotal, discount, total) = ref.watch(
      cartProvider.select((s) => (s.itemCount, s.subtotal, s.discount, s.total)),
    );
    debugPrint('RiverpodSummary rebuilt');
    return SummaryCard(
      itemCount: count,
      subtotal: subtotal,
      discount: discount,
      total: total,
    );
  }
}

// --- Cubit -----------------------------------------------------------------

class CartCubit extends Cubit<CartState> {
  CartCubit(this._api) : super(const CartState());

  final CheckoutApi _api;

  void _mutate(CartState Function(CartState) change) {
    if (state.isSubmitting) return;
    final next = change(state);
    emit(next == state ? next : state.pushed(next));
  }

  void add(Product p) => _mutate((s) => s.added(p));

  void remove(String id) => _mutate((s) => s.removed(id));

  void changeQty(String id, int delta) => _mutate((s) => s.qtyChanged(id, delta));

  void applyCoupon(String code) => _mutate((s) => s.couponApplied(code));

  void undo() {
    if (!state.canUndo || state.isSubmitting) return;
    emit(state.undone());
  }

  Future<void> checkout() async {
    if (state.isSubmitting || state.lines.isEmpty) return;
    emit(state.checkoutStarted());
    try {
      final orderId = await _api.submit(state.total);
      if (isClosed) return;
      emit(state.checkoutSucceeded(orderId));
    } on CheckoutException catch (e) {
      if (isClosed) return;
      emit(state.checkoutFailed(e.message));
    }
  }
}

class CubitCartPage extends StatelessWidget {
  const CubitCartPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => CartCubit(CheckoutApi()),
        child: const _CubitCartView(),
      );
}

class _CubitCartView extends StatelessWidget {
  const _CubitCartView();

  @override
  Widget build(BuildContext context) => BlocListener<CartCubit, CartState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: handleCheckoutStatus,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Cart · Cubit'),
            actions: [
              BlocSelector<CartCubit, CartState, bool>(
                selector: (s) => s.canUndo,
                builder: (context, canUndo) =>
                    UndoAction(canUndo: canUndo, onUndo: context.read<CartCubit>().undo),
              ),
            ],
          ),
          body: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final cubit = context.read<CartCubit>();
              return CartBody(
                lines: state.lines,
                onAdd: cubit.add,
                onQtyChanged: cubit.changeQty,
                couponField: CouponField(error: state.couponError, onApply: cubit.applyCoupon),
                summary: const _CubitSummary(),
                checkoutButton: CheckoutButton(
                  busy: state.isSubmitting,
                  enabled: state.lines.isNotEmpty,
                  onPressed: cubit.checkout,
                ),
              );
            },
          ),
        ),
      );
}

class _CubitSummary extends StatelessWidget {
  const _CubitSummary();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<CartCubit, CartState, (int, double, double, double)>(
        selector: (s) => (s.itemCount, s.subtotal, s.discount, s.total),
        builder: (context, v) {
          debugPrint('CubitSummary rebuilt');
          return SummaryCard(itemCount: v.$1, subtotal: v.$2, discount: v.$3, total: v.$4);
        },
      );
}

// --- Bloc ------------------------------------------------------------------

sealed class CartEvent {
  const CartEvent();
}

final class CartProductAdded extends CartEvent {
  const CartProductAdded(this.product);

  final Product product;
}

final class CartProductRemoved extends CartEvent {
  const CartProductRemoved(this.productId);

  final String productId;
}

final class CartQtyChanged extends CartEvent {
  const CartQtyChanged(this.productId, this.delta);

  final String productId;
  final int delta;
}

final class CartCouponApplied extends CartEvent {
  const CartCouponApplied(this.code);

  final String code;
}

final class CartCheckoutRequested extends CartEvent {
  const CartCheckoutRequested();
}

final class CartUndone extends CartEvent {
  const CartUndone();
}

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc(this._api) : super(const CartState()) {
    on<CartProductAdded>(_onMutation);
    on<CartProductRemoved>(_onMutation);
    on<CartQtyChanged>(_onMutation);
    on<CartCouponApplied>(_onMutation);
    on<CartUndone>(_onUndone);
    on<CartCheckoutRequested>(_onCheckout, transformer: droppable());
  }

  final CheckoutApi _api;

  void _onMutation(CartEvent event, Emitter<CartState> emit) {
    if (state.isSubmitting) return;
    final next = switch (event) {
      CartProductAdded(:final product) => state.added(product),
      CartProductRemoved(:final productId) => state.removed(productId),
      CartQtyChanged(:final productId, :final delta) => state.qtyChanged(productId, delta),
      CartCouponApplied(:final code) => state.couponApplied(code),
      CartCheckoutRequested() || CartUndone() => state,
    };
    emit(next == state ? next : state.pushed(next));
  }

  void _onUndone(CartUndone event, Emitter<CartState> emit) {
    if (!state.canUndo || state.isSubmitting) return;
    emit(state.undone());
  }

  Future<void> _onCheckout(CartCheckoutRequested event, Emitter<CartState> emit) async {
    if (state.lines.isEmpty) return;
    emit(state.checkoutStarted());
    try {
      final orderId = await _api.submit(state.total);
      if (emit.isDone) return;
      emit(state.checkoutSucceeded(orderId));
    } on CheckoutException catch (e) {
      if (emit.isDone) return;
      emit(state.checkoutFailed(e.message));
    }
  }
}

class CartObserver extends BlocObserver {
  String _summary(Object? s) => s is CartState
      ? 'items=${s.itemCount} total=${s.total.toStringAsFixed(2)} ${s.status.name}'
      : '$s';

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    debugPrint(
      '[change] ${bloc.runtimeType}: ${_summary(change.currentState)} -> ${_summary(change.nextState)}',
    );
  }

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    debugPrint(
      '[transition] ${bloc.runtimeType}: ${_summary(transition.currentState)} '
      '--${transition.event.runtimeType}--> ${_summary(transition.nextState)}',
    );
  }
}

class BlocCartPage extends StatelessWidget {
  const BlocCartPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => CartBloc(CheckoutApi()),
        child: const _BlocCartView(),
      );
}

class _BlocCartView extends StatelessWidget {
  const _BlocCartView();

  @override
  Widget build(BuildContext context) => BlocListener<CartBloc, CartState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: handleCheckoutStatus,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Cart · Bloc'),
            actions: [
              BlocSelector<CartBloc, CartState, bool>(
                selector: (s) => s.canUndo,
                builder: (context, canUndo) => UndoAction(
                  canUndo: canUndo,
                  onUndo: () => context.read<CartBloc>().add(const CartUndone()),
                ),
              ),
            ],
          ),
          body: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              final bloc = context.read<CartBloc>();
              return CartBody(
                lines: state.lines,
                onAdd: (p) => bloc.add(CartProductAdded(p)),
                onQtyChanged: (id, delta) => bloc.add(CartQtyChanged(id, delta)),
                couponField: CouponField(
                  error: state.couponError,
                  onApply: (code) => bloc.add(CartCouponApplied(code)),
                ),
                summary: const _BlocSummary(),
                checkoutButton: CheckoutButton(
                  busy: state.isSubmitting,
                  enabled: state.lines.isNotEmpty,
                  onPressed: () => bloc.add(const CartCheckoutRequested()),
                ),
              );
            },
          ),
        ),
      );
}

class _BlocSummary extends StatelessWidget {
  const _BlocSummary();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<CartBloc, CartState, (int, double, double, double)>(
        selector: (s) => (s.itemCount, s.subtotal, s.discount, s.total),
        builder: (context, v) {
          debugPrint('BlocSummary rebuilt');
          return SummaryCard(itemCount: v.$1, subtotal: v.$2, discount: v.$3, total: v.$4);
        },
      );
}
