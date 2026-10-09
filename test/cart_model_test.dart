import 'package:flutter_test/flutter_test.dart';
import 'package:kmart_flutter_ui/models/cart_model.dart';
import 'package:kmart_flutter_ui/models/product_model.dart';

void main() {
  group('CartModel totals', () {
    const apples = ProductModel(
      id: 'product-1',
      name: 'Apples',
      mrp: 100,
      sellingPrice: 80,
    );
    const milk = ProductModel(
      id: 'product-2',
      name: 'Milk',
      mrp: 60,
      sellingPrice: 55,
    );

    const cart = CartModel(
      id: 'cart-1',
      customerId: 'customer-1',
      items: [
        CartItemModel(
          id: 'item-1',
          cartId: 'cart-1',
          productId: 'product-1',
          quantity: 2,
          product: apples,
        ),
        CartItemModel(
          id: 'item-2',
          cartId: 'cart-1',
          productId: 'product-2',
          quantity: 1,
          product: milk,
        ),
      ],
    );

    test('calculates item count, subtotal, MRP and savings', () {
      expect(cart.totalItems, 3);
      expect(cart.subtotal, 215);
      expect(cart.totalMrp, 260);
      expect(cart.totalSavings, 45);
      expect(cart.isEmpty, isFalse);
    });

    test('reports an empty cart', () {
      const emptyCart = CartModel(
        id: 'cart-empty',
        customerId: 'customer-1',
        items: [],
      );

      expect(emptyCart.totalItems, 0);
      expect(emptyCart.subtotal, 0);
      expect(emptyCart.totalSavings, 0);
      expect(emptyCart.isEmpty, isTrue);
    });

    test('copyWith replaces items without mutating the original', () {
      final updatedCart = cart.copyWith(items: const []);

      expect(updatedCart.isEmpty, isTrue);
      expect(cart.totalItems, 3);
    });
  });

  test('cart item total price and savings follow quantity', () {
    const item = CartItemModel(
      id: 'item-1',
      cartId: 'cart-1',
      productId: 'product-1',
      quantity: 3,
      product: ProductModel(
        id: 'product-1',
        name: 'Rice',
        mrp: 120,
        sellingPrice: 100,
      ),
    );

    expect(item.totalPrice, 300);
    expect(item.totalMrp, 360);
    expect(item.totalSavings, 60);
    expect(item.copyWith(quantity: 1).quantity, 1);
  });
}
