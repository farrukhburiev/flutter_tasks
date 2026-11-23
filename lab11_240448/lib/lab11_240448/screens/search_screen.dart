import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../data/product_api.dart';
import '../widgets/product_tile.dart';
import 'details_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (c) => SearchBloc(c.read<ProductApi>()),
        child: const _SearchView(),
      );
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String query) => context.read<SearchBloc>().add(SearchSubmitted(query));

  void _clear() {
    _controller.clear();
    context.read<SearchBloc>().add(const SearchCleared());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(hintText: 'Search products', border: InputBorder.none),
            onSubmitted: _submit,
          ),
          actions: [
            IconButton(tooltip: 'Clear', icon: const Icon(Icons.clear), onPressed: _clear),
          ],
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) => switch (state) {
            SearchIdle() => const _Message(
                icon: Icons.search,
                text: 'Type a product name and press search.',
              ),
            SearchLoading() => const Center(child: CircularProgressIndicator()),
            SearchEmpty(:final query) => _Message(
                icon: Icons.search_off,
                text: 'No products found for "$query".',
              ),
            SearchError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => _submit(_controller.text),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            SearchResults(:final products) => ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, i) => ProductTile(
                  products[i],
                  key: ValueKey(products[i].id),
                  onTap: () => openDetails(context, products[i].id),
                ),
              ),
          },
        ),
      );
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      );
}
