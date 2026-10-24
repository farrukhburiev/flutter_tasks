import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(const ProviderScope(child: TickerApp()));

class TickerApp extends StatelessWidget {
  const TickerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Ticker',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const TickerPage(),
      );
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class Tick {
  const Tick({
    required this.symbol,
    required this.price,
    required this.change,
    required this.at,
  });

  final String symbol;
  final double price;
  final double change;
  final DateTime at;

  bool get isUp => change >= 0;
}

// ---------------------------------------------------------------------------
// Feed
// ---------------------------------------------------------------------------

class FeedException implements Exception {
  const FeedException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TickFeed {
  TickFeed({this.symbols = const ['BTC', 'ETH', 'SOL'], this.failAfter});

  final List<String> symbols;
  final int? failAfter;
  final _rng = Random();
  final _prices = <String, double>{};

  Stream<List<Tick>> watch() async* {
    var count = 0;
    await Future<void>.delayed(const Duration(milliseconds: 800));
    while (true) {
      if (failAfter != null && count >= failAfter!) {
        throw const FeedException('Feed disconnected');
      }
      yield [for (final s in symbols) _next(s)];
      count++;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  Tick _next(String symbol) {
    final prev = _prices[symbol] ?? 100 + _rng.nextDouble() * 900;
    final change = (_rng.nextDouble() - 0.5) * 4;
    final price = (prev + change).clamp(1, double.infinity).toDouble();
    _prices[symbol] = price;
    return Tick(symbol: symbol, price: price, change: change, at: DateTime.now());
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

Duration? _noRetry(int retryCount, Object error) => null;

class FailAfterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? value) => state = value;
}

final failAfterProvider =
    NotifierProvider<FailAfterNotifier, int?>(FailAfterNotifier.new);

final tickFeedProvider = Provider<TickFeed>(
  (ref) => TickFeed(failAfter: ref.watch(failAfterProvider)),
);

final tickerProvider = StreamProvider.autoDispose<List<Tick>>(
  (ref) => ref.watch(tickFeedProvider).watch(),
  retry: _noRetry,
);

final tickProvider = Provider.autoDispose.family<Tick?, String>((ref, symbol) {
  return ref.watch(
    tickerProvider.select(
      (v) => v.value?.where((t) => t.symbol == symbol).firstOrNull,
    ),
  );
});

final balanceProvider = FutureProvider.autoDispose<double>(
  (ref) async {
    final result = await AsyncValue.guard<double>(() async {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (Random().nextInt(3) == 0) {
        throw const FeedException('Balance service unavailable');
      }
      return 1000 + Random().nextDouble() * 9000;
    });
    return result.requireValue;
  },
  retry: _noRetry,
);

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class TickRow extends StatelessWidget {
  const TickRow(this.tick, {super.key});

  final Tick tick;

  @override
  Widget build(BuildContext context) {
    final color = tick.isUp ? Colors.green : Colors.red;
    final arrow = tick.isUp ? '▲' : '▼';
    return ListTile(
      leading: CircleAvatar(child: Text(tick.symbol.substring(0, 1))),
      title: Text(tick.symbol),
      subtitle: Text(tick.price.toStringAsFixed(2)),
      trailing: Text(
        '$arrow ${tick.change.abs().toStringAsFixed(2)}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class LiveTickRow extends ConsumerStatefulWidget {
  const LiveTickRow(this.initial, {super.key});

  final Tick initial;

  @override
  ConsumerState<LiveTickRow> createState() => _LiveTickRowState();
}

class _LiveTickRowState extends ConsumerState<LiveTickRow> {
  Color? _flash;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final symbol = widget.initial.symbol;
    ref.listen<Tick?>(tickProvider(symbol), (previous, next) {
      if (previous == null || next == null || previous.price == next.price) {
        return;
      }
      setState(() => _flash = next.price > previous.price ? Colors.green : Colors.red);
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _flash = null);
      });
    });
    final tick = ref.watch(tickProvider(symbol)) ?? widget.initial;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: _flash?.withValues(alpha: 0.25),
      child: TickRow(tick),
    );
  }
}

class BalanceDialog extends ConsumerWidget {
  const BalanceDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    return AlertDialog(
      title: const Text('Account balance'),
      content: switch (balance) {
        AsyncValue(isLoading: true) => const LinearProgressIndicator(),
        AsyncData(:final value) => Text('\$${value.toStringAsFixed(2)}'),
        AsyncError(:final error) => Text('Error: $error'),
        AsyncLoading() => const LinearProgressIndicator(),
      },
      actions: [
        TextButton(
          onPressed: () => ref.invalidate(balanceProvider),
          child: const Text('Refresh'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class TickerPage extends ConsumerWidget {
  const TickerPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    try {
      await ref.refresh(tickerProvider.future);
    } catch (_) {}
  }

  Widget _plainList(List<Tick> ticks) => ListView(
        children: [for (final t in ticks) LiveTickRow(t, key: ValueKey(t.symbol))],
      );

  Widget _refreshableList(WidgetRef ref, List<Tick> ticks) => RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [for (final t in ticks) LiveTickRow(t, key: ValueKey(t.symbol))],
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticks = ref.watch(tickerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live ticker'),
        actions: [
          IconButton(
            tooltip: 'Simulate feed failure',
            icon: const Icon(Icons.bolt),
            onPressed: () => ref.read(failAfterProvider.notifier).set(5),
          ),
          IconButton(
            tooltip: 'Restore feed',
            icon: const Icon(Icons.power),
            onPressed: () => ref.read(failAfterProvider.notifier).set(null),
          ),
          IconButton(
            tooltip: 'Account balance',
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const BalanceDialog(),
            ),
          ),
        ],
      ),
      body: switch (ticks) {
        AsyncValue(:final value?, isLoading: true) => Column(
            children: [
              const LinearProgressIndicator(),
              Expanded(child: _refreshableList(ref, value)),
            ],
          ),
        AsyncError(isLoading: true) =>
          const Center(child: CircularProgressIndicator()),
        AsyncError(:final error, :final value?) => Column(
            children: [
              MaterialBanner(
                content: Text('Feed error: $error — showing last prices'),
                actions: [
                  TextButton(
                    onPressed: () => ref.invalidate(tickerProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
              Expanded(
                child: Opacity(opacity: 0.5, child: _plainList(value)),
              ),
            ],
          ),
        AsyncError(:final error) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Could not load ticker\n$error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(tickerProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        AsyncData(value: []) => const Center(child: Text('No symbols subscribed')),
        AsyncData(value: [final only]) => Center(child: TickRow(only)),
        AsyncData(:final value) => _refreshableList(ref, value),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}