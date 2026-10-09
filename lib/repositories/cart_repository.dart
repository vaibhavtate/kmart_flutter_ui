import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartRepository {
  CartRepository({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Gets the application customer ID associated with
  /// the currently authenticated Supabase user.
  ///
  /// Important:
  /// auth.users.id != customers.id
  ///
  /// The existing RLS policy on `carts` expects
  /// carts.customer_id to contain customers.id.
  Future<String> _getCurrentCustomerId() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in to use the cart.',
      );
    }

    final response = await _client
        .from('customers')
        .select('id')
        .eq('auth_user_id', user.id)
        .maybeSingle();

    if (response == null) {
      throw Exception(
        'Customer profile not found for the logged-in user.',
      );
    }

    final customerId = response['id'];

    if (customerId == null) {
      throw Exception(
        'Customer ID is missing for the logged-in user.',
      );
    }

    return customerId.toString();
  }

  Future<CartModel?> getCart() async {
    final customerId = await _getCurrentCustomerId();

    final cartResponse = await _client
        .from('carts')
        .select('id, customer_id, updated_at')
        .eq('customer_id', customerId)
        .maybeSingle();

    if (cartResponse == null) {
      return null;
    }

    final cart = Map<String, dynamic>.from(
      cartResponse,
    );

    final cartId = '${cart['id']}';

    final itemResponse = await _client
        .from('cart_items')
        .select(
          'id, cart_id, product_id, quantity',
        )
        .eq('cart_id', cartId)
        .order('id');

    final itemRows = (itemResponse as List)
        .map(
          (row) => Map<String, dynamic>.from(
            row as Map,
          ),
        )
        .toList();

    if (itemRows.isEmpty) {
      return CartModel(
        id: cartId,
        customerId: '${cart['customer_id']}',
        items: const [],
        updatedAt: _parseDate(
          cart['updated_at'],
        ),
      );
    }

    final productIds = itemRows
        .map(
          (row) => '${row['product_id']}',
        )
        .toSet()
        .toList();

    final productResponse = await _client
        .from('products')
        .select()
        .inFilter('id', productIds);

    final productById = <String, ProductModel>{};

    for (final row in productResponse as List) {
      final map = Map<String, dynamic>.from(
        row as Map,
      );

      final product = ProductModel.fromMap(map);

      productById[product.id] = product;
    }

    final items = <CartItemModel>[];

    for (final row in itemRows) {
      final productId = '${row['product_id']}';
      final product = productById[productId];

      if (product == null) {
        continue;
      }

      final quantity = _parseInt(
        row['quantity'],
      );

      if (quantity <= 0) {
        continue;
      }

      items.add(
        CartItemModel(
          id: '${row['id']}',
          cartId: '${row['cart_id']}',
          productId: productId,
          quantity: quantity,
          product: product,
        ),
      );
    }

    return CartModel(
      id: cartId,
      customerId: '${cart['customer_id']}',
      items: items,
      updatedAt: _parseDate(
        cart['updated_at'],
      ),
    );
  }

  Future<CartModel> getOrCreateCart() async {
    final customerId = await _getCurrentCustomerId();

    final existing = await getCart();

    if (existing != null) {
      return existing;
    }

    final response = await _client
        .from('carts')
        .insert({
          'customer_id': customerId,
        })
        .select(
          'id, customer_id, updated_at',
        )
        .single();

    final cart = Map<String, dynamic>.from(
      response,
    );

    return CartModel(
      id: '${cart['id']}',
      customerId: '${cart['customer_id']}',
      items: const [],
      updatedAt: _parseDate(
        cart['updated_at'],
      ),
    );
  }

  Future<void> addItem({
    required String productId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      return;
    }

    final cart = await getOrCreateCart();

    final existing = await _client
        .from('cart_items')
        .select('id, quantity')
        .eq('cart_id', cart.id)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing == null) {
      await _client.from('cart_items').insert({
        'cart_id': cart.id,
        'product_id': productId,
        'quantity': quantity,
      });

      return;
    }

    final existingMap = Map<String, dynamic>.from(
      existing,
    );

    final currentQuantity = _parseInt(
      existingMap['quantity'],
    );

    await _client
        .from('cart_items')
        .update({
          'quantity': currentQuantity + quantity,
        })
        .eq(
          'id',
          '${existingMap['id']}',
        );
  }

  Future<void> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await removeItem(cartItemId);
      return;
    }

    await _client
        .from('cart_items')
        .update({
          'quantity': quantity,
        })
        .eq(
          'id',
          cartItemId,
        );
  }

  Future<void> removeItem(
    String cartItemId,
  ) async {
    await _client
        .from('cart_items')
        .delete()
        .eq(
          'id',
          cartItemId,
        );
  }

  Future<void> clearCart() async {
    final cart = await getCart();

    if (cart == null) {
      return;
    }

    await _client
        .from('cart_items')
        .delete()
        .eq(
          'cart_id',
          cart.id,
        );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          '$value',
        ) ??
        0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      '$value',
    );
  }
}