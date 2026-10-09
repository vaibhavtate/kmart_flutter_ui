import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class KMartMobileHeader extends StatefulWidget {
  const KMartMobileHeader({
    super.key,
    this.address,
    this.onLocationTap,
    this.onSearch,
    this.onCartTap,
    this.cartCount = 0,
  });

  final String? address;
  final VoidCallback? onLocationTap;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onCartTap;
  final int cartCount;

  @override
  State<KMartMobileHeader> createState() => _KMartMobileHeaderState();
}

class _KMartMobileHeaderState extends State<KMartMobileHeader> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  _Logo(),
                  const SizedBox(width: 10),
                  Expanded(child: _Location(onTap: widget.onLocationTap, address: widget.address)),
                  const SizedBox(width: 8),
                  _Cart(onTap: widget.onCartTap, count: widget.cartCount),
                ],
              ),
              const SizedBox(height: 12),
              _SearchField(
                controller: _controller,
                onSubmitted: widget.onSearch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 36,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Text(
          'K MART',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.navy),
        ),
      ),
    );
  }
}

class _Location extends StatelessWidget {
  const _Location({required this.onTap, required this.address});
  final VoidCallback? onTap;
  final String? address;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primary, size: 19),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Deliver to', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.1)),
                  Text(
                    address?.trim().isNotEmpty == true ? address! : 'Select delivery location',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, this.onSubmitted});
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search products, brands and more',
        prefixIcon: const Icon(Icons.search, color: AppColors.navy, size: 21),
        suffixIcon: IconButton(
          onPressed: () => onSubmitted?.call(controller.text.trim()),
          icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 21),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F6F8),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
    );
  }
}

class _Cart extends StatelessWidget {
  const _Cart({required this.onTap, required this.count});
  final VoidCallback? onTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(11),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(11),
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(Icons.shopping_cart_outlined, color: AppColors.navy, size: 22),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            right: -4,
            top: -5,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white, width: 2)),
              child: Center(
                child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
      ],
    );
  }
}
