import '../repositories/cart_repository.dart';

class CartService {
  CartService({
    required CartRepository repository,
  }) : _repository = repository;

  final CartRepository _repository;

  Future getCart() {
    return _repository.getCart();
  }

  Future addToCart({
    required String productId,
    required int quantity,
  }) {
    return _repository.addItem(
      productId: productId,
      quantity: quantity,
    );
  }

  Future updateQuantity({
    required String cartItemId,
    required int quantity,
  }) {
    return _repository.updateItemQuantity(
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }

  Future removeItem(
    String cartItemId,
  ) {
    return _repository.removeItem(cartItemId);
  }

  Future clearCart() {
    return _repository.clearCart();
  }
}