import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class KMartHeader extends StatefulWidget {
  const KMartHeader({
    super.key,
    this.selectedAddress,
    this.categories = const [
      'Groceries',
      'Fruits & Vegetables',
      'Dairy & Eggs',
      'Snacks & Beverages',
      'Personal Care',
      'Household',
    ],
    this.selectedCategory = 'all',
    this.onLocationTap,
    this.onSearch,
    this.onOrdersTap,
    this.onAccountTap,
    this.onCartTap,
    this.onCategoryTap,
    this.onAllCategoriesTap,
  });

  final String? selectedAddress;
  final List<String> categories;
  final String selectedCategory;
  final VoidCallback? onLocationTap;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onAccountTap;
  final VoidCallback? onCartTap;
  final ValueChanged<String>? onCategoryTap;
  final VoidCallback? onAllCategoriesTap;

  @override
  State<KMartHeader> createState() => _KMartHeaderState();
}

class _KMartHeaderState extends State<KMartHeader> {
  late final TextEditingController _searchController;
  bool _searchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildMainRow(context), _buildCategoryRow(context)],
      ),
    );
  }

  Widget _buildMainRow(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;

        if (compact) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildLogo(width: 88, height: 43),
                    const Spacer(),
                    _HeaderTextButton(
                      label: 'Orders',
                      icon: Icons.receipt_long_outlined,
                      onTap: widget.onOrdersTap,
                      compact: true,
                    ),
                    _HeaderTextButton(
                      label: 'Account',
                      icon: Icons.person_outline,
                      onTap: widget.onAccountTap,
                      compact: true,
                    ),
                    _CartButton(onTap: widget.onCartTap),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSearchField(),
                const SizedBox(height: 8),
                _buildLocationButton(),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              _buildLogo(width: 100, height: 48),
              const SizedBox(width: 22),
              _buildLocationButton(),
              const SizedBox(width: 24),
              Expanded(child: _buildSearchField()),
              const SizedBox(width: 24),
              _HeaderTextButton(label: 'Orders', onTap: widget.onOrdersTap),
              const SizedBox(width: 22),
              _HeaderTextButton(label: 'Account', onTap: widget.onAccountTap),
              const SizedBox(width: 22),
              _CartButton(onTap: widget.onCartTap),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo({required double width, required double height}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        'assets/images/logo.png',
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: Text(
              'K MART',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return InkWell(
      onTap: widget.onLocationTap,
      borderRadius: BorderRadius.circular(9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Deliver to',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.1,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          widget.selectedAddress?.trim().isNotEmpty == true
                              ? widget.selectedAddress!
                              : 'Baramati 413102',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Focus(
      onFocusChange: (focused) => setState(() => _searchFocused = focused),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: widget.onSearch,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search products, brands and more...',
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: Color(0xFF9CA3AF),
          ),
          suffixIcon: _searchController.text.isEmpty
              ? Container(
                  margin: const EdgeInsets.all(4),
                  child: FilledButton(
                    onPressed: () =>
                        widget.onSearch?.call(_searchController.text.trim()),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  tooltip: 'Clear',
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close, size: 18),
                ),
          filled: true,
          fillColor: _searchFocused ? Colors.white : const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            InkWell(
              onTap: widget.onAllCategoriesTap,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(Icons.menu, size: 17, color: AppColors.navy),
                    SizedBox(width: 5),
                    Text(
                      'All Categories',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (final category in widget.categories)
              _CategoryButton(
                label: category,
                selected: _slug(category) == widget.selectedCategory,
                onTap: () => widget.onCategoryTap?.call(category),
              ),
          ],
        ),
      ),
    );
  }

  String _slug(String value) => value
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.primary : const Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderTextButton extends StatelessWidget {
  const _HeaderTextButton({
    required this.label,
    this.icon,
    this.onTap,
    this.compact = false,
  });
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.navy,
        padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 0),
      ),
      child: icon == null
          ? Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 19),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.navy,
        padding: EdgeInsets.zero,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 21),
          SizedBox(width: 5),
          Text(
            'Cart',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
