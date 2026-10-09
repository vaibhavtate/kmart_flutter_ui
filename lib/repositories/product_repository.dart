import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductRepository {
  ProductRepository({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // Customer-visible stock threshold.
  // Products must have MORE than this quantity.
  static const double customerStockThreshold = 5;

  // ------------------------------------------------------------
  // CATEGORIES
  // ------------------------------------------------------------

  Future<List<CategoryModel>> getActiveCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('name');

    return (response as List)
        .map(
          (row) => CategoryModel.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  // ------------------------------------------------------------
  // PRODUCTS
  // ------------------------------------------------------------

  Future<List<ProductModel>> getActiveProducts({
    int limit = 24,
    required String storeId,
  }) async {
    if (storeId.trim().isEmpty) {
      return [];
    }

    // First get inventory that is actually customer-visible.
    //
    // IMPORTANT:
    // stock_quantity must be > 5.
    final inventoryResponse = await _client
        .from('inventory')
        .select('product_id, stock_quantity')
        .eq('store_id', storeId)
        .gt('stock_quantity', customerStockThreshold);

    if (
        inventoryResponse.isEmpty) {
      return [];
    }

    final stockByProduct = <String, double>{};

    for (final row in inventoryResponse) {
      final map = Map<String, dynamic>.from(row as Map);

      final productId = map['product_id']?.toString();

      if (productId == null || productId.isEmpty) {
        continue;
      }

      final quantity = map['stock_quantity'];

      final stock = quantity is num
          ? quantity.toDouble()
          : double.tryParse('$quantity') ?? 0;

      if (stock > customerStockThreshold) {
        stockByProduct[productId] = stock;
      }
    }

    if (stockByProduct.isEmpty) {
      return [];
    }

    final productIds = stockByProduct.keys.toList();

    final response = await _client
        .from('products')
        .select()
        .eq('active', true)
        .inFilter('id', productIds)
        .order('created_at', ascending: false)
        .limit(limit);

    final products = (response as List)
        .map(
          (row) => ProductModel.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();

    return products
        .map(
          (product) => ProductModel(
            id: product.id,
            name: product.name,
            mrp: product.mrp,
            sellingPrice: product.sellingPrice,
            taxPercent: product.taxPercent,
            imageUrl: product.imageUrl,
            categoryId: product.categoryId,
            categoryName: product.categoryName,
            active: product.active,
            stockQuantity: stockByProduct[product.id],
          ),
        )
        .where(
          (product) =>
              product.stockQuantity != null &&
              product.stockQuantity! > customerStockThreshold,
        )
        .toList();
  }

  // ------------------------------------------------------------
  // PRODUCT SEARCH
  // ------------------------------------------------------------

  Future<List<ProductModel>> searchProducts({
    required String query,
    required String storeId,
    int limit = 30,
  }) async {
    final search = query.trim();

    if (search.isEmpty || storeId.trim().isEmpty) {
      return [];
    }

    // Only inventory with MORE than 5 units is customer-visible.
    final inventoryResponse = await _client
        .from('inventory')
        .select('product_id, stock_quantity')
        .eq('store_id', storeId)
        .gt('stock_quantity', customerStockThreshold);

    if (
        inventoryResponse.isEmpty) {
      return [];
    }

    final stockByProduct = <String, double>{};

    for (final row in inventoryResponse) {
      final map = Map<String, dynamic>.from(row as Map);

      final productId = map['product_id']?.toString();

      if (productId == null || productId.isEmpty) {
        continue;
      }

      final quantity = map['stock_quantity'];

      final stock = quantity is num
          ? quantity.toDouble()
          : double.tryParse('$quantity') ?? 0;

      if (stock > customerStockThreshold) {
        stockByProduct[productId] = stock;
      }
    }

    if (stockByProduct.isEmpty) {
      return [];
    }

    final productIds = stockByProduct.keys.toList();

    final response = await _client
        .from('products')
        .select()
        .eq('active', true)
        .ilike('name', '%$search%')
        .inFilter('id', productIds)
        .limit(limit);

    final products = (response as List)
        .map(
          (row) => ProductModel.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();

    return products
        .map(
          (product) => ProductModel(
            id: product.id,
            name: product.name,
            mrp: product.mrp,
            sellingPrice: product.sellingPrice,
            taxPercent: product.taxPercent,
            imageUrl: product.imageUrl,
            categoryId: product.categoryId,
            categoryName: product.categoryName,
            active: product.active,
            stockQuantity: stockByProduct[product.id],
          ),
        )
        .where(
          (product) =>
              product.stockQuantity != null &&
              product.stockQuantity! > customerStockThreshold,
        )
        .toList();
  }
}