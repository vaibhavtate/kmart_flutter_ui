import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  String _query = '';

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialQuery);

    _query = widget.initialQuery.trim();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    setState(() {
      _query = value.trim();
    });
  }

  void _clearSearch() {
    _controller.clear();

    setState(() {
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = _query.isEmpty
        ? null
        : ref.watch(searchProductsProvider(_query));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(child: _buildResults(searchAsync)),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onChanged: _search,
        onSubmitted: _search,
        decoration: InputDecoration(
          hintText: 'Search products',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(AsyncValue<List<ProductModel>>? searchAsync) {
    if (_query.isEmpty) {
      return const _SearchInitialState();
    }

    if (searchAsync == null) {
      return const SizedBox.shrink();
    }

    return searchAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, stack) => _SearchError(
        error: error,
        onRetry: () {
          ref.invalidate(searchProductsProvider(_query));
        },
      ),
      data: (products) {
        if (products.isEmpty) {
          return const _NoResults();
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(searchProductsProvider(_query));

            await ref.read(searchProductsProvider(_query).future);
          },
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .67,
            ),
            itemCount: products.length,
            itemBuilder: (_, index) {
              return _SearchProductCard(product: products[index]);
            },
          ),
        );
      },
    );
  }
}

class _SearchInitialState extends StatelessWidget {
  const _SearchInitialState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Search K Mart',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find groceries and everyday products by name.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 42,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No products found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different product name or search term.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  const _SearchError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 44, color: Colors.red),
            const SizedBox(height: 14),
            const Text(
              'Unable to search products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchProductCard extends StatelessWidget {
  const _SearchProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent.round();

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (product.hasDiscount)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '$discount% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              const Spacer(),
              const Icon(Icons.favorite_border, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: _ProductImage(url: product.imageUrl),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            product.categoryName ?? 'K MART',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '\u20B9${product.sellingPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              if (product.hasDiscount) ...[
                const SizedBox(width: 5),
                Text(
                  '\u20B9${product.mrp.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF9CA3AF),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: double.infinity,
            height: 29,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: const Text(
                'ADD +',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return Container(
        color: AppColors.background,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          size: 40,
          color: AppColors.textSecondary,
        ),
      );
    }

    return Image.network(
      url!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) {
        return Container(
          color: AppColors.background,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: AppColors.textSecondary,
          ),
        );
      },
    );
  }
}
