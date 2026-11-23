import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/details_cubit.dart';
import '../data/product_api.dart';
import '../models/product.dart';
import '../models/review.dart';

void openDetails(BuildContext context, int productId) => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DetailsScreen(productId: productId)),
    );

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (c) => DetailsCubit(c.read<ProductApi>(), productId)..load(),
        child: Scaffold(
          appBar: AppBar(title: const Text('Details')),
          body: BlocBuilder<DetailsCubit, DetailsState>(
            builder: (context, state) => switch (state) {
              DetailsLoading() => const Center(child: CircularProgressIndicator()),
              DetailsError(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(message, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => context.read<DetailsCubit>().load(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              DetailsLoaded(:final product) => _DetailsBody(product),
            },
          ),
        ),
      );
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final images = product.images.isEmpty ? [product.thumbnail] : product.images;
    final d = product.dimensions;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final url in images)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Image.network(
                    url,
                    height: 220,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 220,
                      child: Icon(Icons.image_not_supported_outlined, size: 48),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(product.title, style: textTheme.headlineSmall),
        if (product.brand != null) Text(product.brand!, style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('\$${product.price.toStringAsFixed(2)} · ★ ${product.rating.toStringAsFixed(1)}'),
        const SizedBox(height: 12),
        Text(product.description),
        const SizedBox(height: 12),
        Text(
          'Dimensions: ${d.width} × ${d.height} × ${d.depth}',
          style: textTheme.bodyMedium,
        ),
        if (product.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [for (final tag in product.tags) Chip(label: Text(tag))],
          ),
        ],
        const SizedBox(height: 16),
        Text('Reviews (${product.reviews.length})', style: textTheme.titleLarge),
        for (final review in product.reviews) _ReviewTile(review),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile(this.review);

  final Review review;

  String get _date {
    final d = review.date.toLocal();
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          children: [
            for (var i = 1; i <= 5; i++)
              Icon(
                i <= review.rating ? Icons.star : Icons.star_border,
                size: 16,
                color: Colors.amber,
              ),
            const SizedBox(width: 8),
            Expanded(child: Text(review.reviewerName, overflow: TextOverflow.ellipsis)),
          ],
        ),
        subtitle: Text('${review.comment}\n$_date'),
        isThreeLine: true,
      );
}
