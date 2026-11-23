import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/products_cubit.dart';
import '../data/product_api.dart';
import '../widgets/product_tile.dart';
import 'details_screen.dart';
import 'search_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (c) => ProductsCubit(c.read<ProductApi>())..load(),
        child: const _ProductsView(),
      );
}

class _ProductsView extends StatelessWidget {
  const _ProductsView();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Products'),
          actions: [
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
              ),
            ),
          ],
        ),
        body: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) => switch (state) {
            ProductsLoading() => const Center(child: CircularProgressIndicator()),
            ProductsError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.read<ProductsCubit>().load(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            final ProductsLoaded loaded => _ProductList(loaded),
          },
        ),
      );
}

class _ProductList extends StatelessWidget {
  const _ProductList(this.state);

  final ProductsLoaded state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductsCubit>();
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.products.length + 1,
        itemBuilder: (context, i) {
          if (i < state.products.length) {
            final product = state.products[i];
            return ProductTile(
              product,
              key: ValueKey(product.id),
              onTap: () => openDetails(context, product.id),
            );
          }
          return _Footer(state: state, onLoadMore: cubit.loadMore);
        },
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onLoadMore});

  final ProductsLoaded state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (!state.hasMore && state.errorMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (state.hasMore)
            state.isLoadingMore
                ? const CircularProgressIndicator()
                : FilledButton.tonal(
                    onPressed: onLoadMore,
                    child: Text('Load more (${state.products.length} of ${state.total})'),
                  ),
        ],
      ),
    );
  }
}
