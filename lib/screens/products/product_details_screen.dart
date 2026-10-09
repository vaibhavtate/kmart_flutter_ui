import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../cart/cart_screen.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends ConsumerState<ProductDetailsScreen> {
  int _quantity = 1;

  ProductModel get product => widget.product;

  bool get hasStock =>
      product.stockQuantity == null ||
      product.stockQuantity! > 0;

  bool get isLowStock =>
      product.stockQuantity != null &&
      product.stockQuantity! > 0 &&
      product.stockQuantity! <= 5;

  double get totalPrice =>
      product.sellingPrice * _quantity;

  void _increaseQuantity() {
    if (!hasStock) return;

    final stock = product.stockQuantity;

    if (stock != null && _quantity >= stock) {
      return;
    }

    setState(() {
      _quantity++;
    });
  }

  void _decreaseQuantity() {
    if (_quantity <= 1) return;

    setState(() {
      _quantity--;
    });
  }

  Future<void> _addToCart() async {
    if (!hasStock) return;

    final success = await ref
        .read(cartProvider)
        .addToCart(
          productId: product.id,
          quantity: _quantity,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${product.name} added to cart.',
          ),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'VIEW CART',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
            },
          ),
        ),
      );
    } else {
      final error = ref.read(cartProvider).error;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error?.toString() ??
                'Unable to add product to cart.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent.round();

    final cartController = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
          color: AppColors.textPrimary,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CartScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                ),
                color: AppColors.textPrimary,
              ),
              if (cartController.itemCount > 0)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 17,
                      minHeight: 17,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartController.itemCount > 99
                          ? '99+'
                          : '${cartController.itemCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.favorite_border,
            ),
            color: AppColors.textPrimary,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                14,
                14,
                14,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImage(discount),
                  const SizedBox(height: 18),
                  _buildProductInformation(),
                  const SizedBox(height: 18),
                  _buildPriceSection(),
                  const SizedBox(height: 18),
                  _buildStockSection(),
                  const SizedBox(height: 20),
                  _buildQuantitySection(),
                  const SizedBox(height: 22),
                  _buildProductInformationSection(),
                ],
              ),
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildProductImage(int discount) {
    return Container(
      width: double.infinity,
      height: 330,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _ProductImage(
                imageUrl: product.imageUrl,
              ),
            ),
          ),
          if (product.hasDiscount)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '$discount% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          if (!hasStock)
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'OUT OF STOCK',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.categoryName ?? 'K MART',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: .6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          product.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            height: 1.15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\u20B9${product.sellingPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (product.hasDiscount) ...[
            const SizedBox(width: 9),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '\u20B9${product.mrp.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (product.hasDiscount)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: .09,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'SAVE ${_formatMoney(product.mrp - product.sellingPrice)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStockSection() {
    if (!hasStock) {
      return _StockMessage(
        icon: Icons.remove_shopping_cart_outlined,
        color: const Color(0xFFDC2626),
        background: const Color(0xFFFEE2E2),
        title: 'Currently unavailable',
        subtitle: 'This product is currently out of stock.',
      );
    }

    if (isLowStock) {
      return _StockMessage(
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFD97706),
        background: const Color(0xFFFEF3C7),
        title:
            'Only ${product.stockQuantity!.toStringAsFixed(0)} left',
        subtitle: 'Order soon before it sells out.',
      );
    }

    if (product.stockQuantity != null) {
      return _StockMessage(
        icon: Icons.check_circle_outline,
        color: AppColors.primary,
        background: const Color(0xFFDCFCE7),
        title: 'In stock',
        subtitle:
            '${product.stockQuantity!.toStringAsFixed(0)} units available',
      );
    }

    return _StockMessage(
      icon: Icons.check_circle_outline,
      color: AppColors.primary,
      background: const Color(0xFFDCFCE7),
      title: 'Available',
      subtitle: 'This product is currently available.',
    );
  }

  Widget _buildQuantitySection() {
    final cartController = ref.watch(cartProvider);

    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quantity',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Select quantity',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: hasStock &&
                        _quantity > 1 &&
                        !cartController.isUpdating
                    ? _decreaseQuantity
                    : null,
                icon: const Icon(
                  Icons.remove,
                  size: 18,
                ),
                color: AppColors.primary,
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '$_quantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: hasStock &&
                        !cartController.isUpdating
                    ? _increaseQuantity
                    : null,
                icon: const Icon(
                  Icons.add,
                  size: 18,
                ),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductInformationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Information',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Product',
            value: product.name,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'MRP',
            value:
                '\u20B9${product.mrp.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Selling Price',
            value:
                '\u20B9${product.sellingPrice.toStringAsFixed(0)}',
          ),
          if (product.taxPercent != null) ...[
            const SizedBox(height: 10),
            _InfoRow(
              label: 'Tax',
              value:
                  '${product.taxPercent!.toStringAsFixed(2)}%',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    final cartController = ref.watch(cartProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        10,
        14,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\u20B9${totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: hasStock &&
                          !cartController.isUpdating
                      ? _addToCart
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        const Color(0xFFE5E7EB),
                    foregroundColor: Colors.white,
                    disabledForegroundColor:
                        const Color(0xFF9CA3AF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  icon: cartController.isUpdating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.shopping_cart_outlined,
                          size: 19,
                        ),
                  label: Text(
                    cartController.isUpdating
                        ? 'Adding...'
                        : hasStock
                            ? 'Add to Cart'
                            : 'Out of Stock',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMoney(double value) {
    return value.toStringAsFixed(0);
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null ||
        imageUrl!.trim().isEmpty) {
      return Container(
        color: AppColors.background,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          size: 64,
          color: AppColors.textSecondary,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.background,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 56,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _StockMessage extends StatelessWidget {
  const _StockMessage({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color.withValues(alpha: .85),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}