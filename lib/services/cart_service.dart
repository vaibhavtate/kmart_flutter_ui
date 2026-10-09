import '../models/cart_model.dart';
import '../repositories/cart_repository.dart';

class CartService {
  CartService({required this._repository});

  final CartRepository _repository;

  Future<CartModel?> getCart() {
    return _repository.getCart();
  }

  Future<void> addToCart({required String productId, required int quantity}) {
    return _repository.addItem(productId: productId, quantity: quantity);
  }

  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) {
    return _repository.updateItemQuantity(
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }

  Future<void> removeItem(String cartItemId) {
    return _repository.removeItem(cartItemId);
  }

  Future<void> clearCart() {
    return _repository.clearCart();
  }
}
