import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/product_api.dart';
import 'screens/products_screen.dart';

void main() => runApp(const CatalogApp());

class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key});

  @override
  Widget build(BuildContext context) => RepositoryProvider(
        create: (_) => ProductApi(),
        child: MaterialApp(
          title: 'Catalogue',
          theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
          home: const ProductsScreen(),
        ),
      );
}
