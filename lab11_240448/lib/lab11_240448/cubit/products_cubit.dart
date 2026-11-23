import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_api.dart';
import '../models/product.dart';

sealed class ProductsState {
  const ProductsState();
}

final class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

final class ProductsError extends ProductsState {
  const ProductsError(this.message);

  final String message;
}

final class ProductsLoaded extends ProductsState {
  const ProductsLoaded(
    this.products, {
    required this.total,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<Product> products;
  final int total;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => products.length < total;

  ProductsLoaded copyWith({bool? isLoadingMore, String? errorMessage, bool clearError = false}) =>
      ProductsLoaded(
        products,
        total: total,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._api) : super(const ProductsLoading());

  final ProductApi _api;

  static const pageSize = 20;

  Future<void> load() async {
    emit(const ProductsLoading());
    try {
      final page = await _api.getProducts(limit: pageSize);
      if (isClosed) return;
      emit(ProductsLoaded(page.products, total: page.total));
    } on ApiException catch (e) {
      if (!isClosed) emit(ProductsError(e.message));
    }
  }

  Future<void> refresh() async {
    try {
      final page = await _api.getProducts(limit: pageSize);
      if (isClosed) return;
      emit(ProductsLoaded(page.products, total: page.total));
    } on ApiException catch (e) {
      if (isClosed) return;
      final current = state;
      emit(
        current is ProductsLoaded
            ? ProductsLoaded(current.products, total: current.total, errorMessage: e.message)
            : ProductsError(e.message),
      );
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! ProductsLoaded || !current.hasMore || current.isLoadingMore) return;
    emit(current.copyWith(isLoadingMore: true, clearError: true));
    try {
      final page = await _api.getProducts(limit: pageSize, skip: current.products.length);
      if (isClosed) return;
      emit(ProductsLoaded([...current.products, ...page.products], total: page.total));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(ProductsLoaded(current.products, total: current.total, errorMessage: e.message));
    }
  }
}
