import '../models/product_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.product,
  });

  final String id;
  final String cartId;
  final String productId;
  final int quantity;
  final ProductModel product;

  double get totalPrice =>
      product.sellingPrice * quantity;

  double get totalMrp =>
      product.mrp * quantity;

  double get totalSavings =>
      totalMrp - totalPrice;

  CartItemModel copyWith({
    int? quantity,
  }) {
    return CartItemModel(
      id: id,
      cartId: cartId,
      productId: productId,
      quantity: quantity ?? this.quantity,
      product: product,
    );
  }
}

class CartModel {
  const CartModel({
    required this.id,
    required this.customerId,
    required this.items,
    this.updatedAt,
  });

  final String id;
  final String customerId;
  final List<CartItemModel> items;
  final DateTime? updatedAt;

  int get totalItems {
    return items.fold(
      0,
      (total, item) => total + item.quantity,
    );
  }

  double get subtotal {
    return items.fold(
      0,
      (total, item) => total + item.totalPrice,
    );
  }

  double get totalMrp {
    return items.fold(
      0,
      (total, item) => total + item.totalMrp,
    );
  }

  double get totalSavings {
    return totalMrp - subtotal;
  }

  bool get isEmpty => items.isEmpty;

  CartModel copyWith({
    List<CartItemModel>? items,
  }) {
    return CartModel(
      id: id,
      customerId: customerId,
      items: items ?? this.items,
      updatedAt: updatedAt,
    );
  }
}