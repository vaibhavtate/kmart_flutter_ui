import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import 'location_provider.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) {
    return ProductRepository();
  },
);

final homeCategoriesProvider =
    FutureProvider.autoDispose<List<CategoryModel>>(
  (ref) async {
    final repository =
        ref.watch(productRepositoryProvider);

    return repository.getActiveCategories();
  },
);

final homeProductsProvider =
    FutureProvider.autoDispose<List<ProductModel>>(
  (ref) async {
    final repository =
        ref.watch(productRepositoryProvider);

    final locationState =
        ref.watch(locationProvider);

    final storeId =
        locationState.selectedStore?.id;

    if (storeId == null || storeId.isEmpty) {
      return [];
    }

    return repository.getActiveProducts(
      limit: 24,
      storeId: storeId,
    );
  },
);

final searchProductsProvider =
    FutureProvider.autoDispose.family<
        List<ProductModel>,
        String>(
  (ref, query) async {
    final repository =
        ref.watch(productRepositoryProvider);

    final locationState =
        ref.watch(locationProvider);

    final storeId =
        locationState.selectedStore?.id;

    if (storeId == null || storeId.isEmpty) {
      return [];
    }

    return repository.searchProducts(
      query: query,
      storeId: storeId,
      limit: 30,
    );
  },
);