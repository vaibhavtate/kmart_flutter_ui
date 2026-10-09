import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/cart_model.dart';
import '../repositories/cart_repository.dart';
import '../services/cart_service.dart';

final cartRepositoryProvider =
    Provider<CartRepository>((ref) {
  return CartRepository();
});

final cartServiceProvider =
    Provider<CartService>((ref) {
  return CartService(
    repository: ref.watch(
      cartRepositoryProvider,
    ),
  );
});

final cartProvider =
    ChangeNotifierProvider<CartController>((ref) {
  return CartController(
    service: ref.watch(
      cartServiceProvider,
    ),
  );
});

class CartController extends ChangeNotifier {
  CartController({
    required CartService service,
  }) : _service = service;

  final CartService _service;

  CartModel? _cart;

  bool _isLoading = false;
  bool _isUpdating = false;

  Object? _error;

  CartModel? get cart => _cart;

  bool get isLoading => _isLoading;

  bool get isUpdating => _isUpdating;

  Object? get error => _error;

  int get itemCount => _cart?.totalItems ?? 0;

  double get subtotal => _cart?.subtotal ?? 0;

  double get totalMrp => _cart?.totalMrp ?? 0;

  double get totalSavings => _cart?.totalSavings ?? 0;

  bool get isEmpty =>
      _cart == null || _cart!.items.isEmpty;

  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      _cart = await _service.getCart();
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart({
    required String productId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      return false;
    }

    _isUpdating = true;
    _error = null;

    notifyListeners();

    try {
      await _service.addToCart(
        productId: productId,
        quantity: quantity,
      );

      _cart = await _service.getCart();

      return true;
    } catch (error) {
      _error = error;
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    _isUpdating = true;
    _error = null;

    notifyListeners();

    try {
      await _service.updateQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );

      _cart = await _service.getCart();

      return true;
    } catch (error) {
      _error = error;
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> removeItem(
    String cartItemId,
  ) async {
    _isUpdating = true;
    _error = null;

    notifyListeners();

    try {
      await _service.removeItem(
        cartItemId,
      );

      _cart = await _service.getCart();

      return true;
    } catch (error) {
      _error = error;
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> clearCart() async {
    _isUpdating = true;
    _error = null;

    notifyListeners();

    try {
      await _service.clearCart();

      _cart = await _service.getCart();

      return true;
    } catch (error) {
      _error = error;
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}