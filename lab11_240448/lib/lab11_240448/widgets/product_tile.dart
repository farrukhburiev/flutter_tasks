import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductTile extends StatelessWidget {
  const ProductTile(this.product, {super.key, this.onTap});

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: SizedBox(
          width: 56,
          height: 56,
          child: Image.network(
            product.thumbnail,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined),
          ),
        ),
        title: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('\$${product.price.toStringAsFixed(2)} · ★ ${product.rating.toStringAsFixed(1)}'),
      );
}
