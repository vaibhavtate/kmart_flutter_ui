import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../products/product_listing_screen.dart';
import '../categories/categories_screen.dart';
import '../search/search_screen.dart';
import '../products/product_details_screen.dart';
import '../../providers/location_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/header/kmart_bottom_nav.dart';
import '../../core/widgets/header/kmart_mobile_header.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;
  int _heroIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(cartProvider).loadCart();
    });
  }

  static const List<_HeroData> _heroSlides = [
    _HeroData(
      'STAPLES & PANTRY',
      'Save More on Everyday Essentials',
      'Trusted groceries and daily essentials at great prices.',
      'Shop Offers',
      'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=800&q=80',
    ),
    _HeroData(
      'FRESH & EVERYDAY',
      'Everything You Need, Delivered',
      'Shop groceries, beverages, household essentials and more.',
      'Explore Now',
      'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=800&q=80',
    ),
    _HeroData(
      'K MART DEALS',
      'Save More on Your Daily Shopping',
      'Discover value across your favourite everyday products.',
      'View Deals',
      'https://images.unsplash.com/photo-1601598851547-4302969d9e4f?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(homeCategoriesProvider);
    final products = ref.watch(homeProductsProvider);
    final locationState = ref.watch(locationProvider);
    final cartController = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          KMartMobileHeader(
            address: locationState.selectedAddress,
            cartCount: cartController.itemCount,
            onLocationTap: () {
              context.push('/location');
            },
            onSearch: (query) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SearchScreen(initialQuery: query),
                ),
              );
            },
            onCartTap: () => context.push('/cart'),
          ),
          Expanded(
            child:
                (locationState.selectedStore == null ||
                    !locationState.isDeliverable)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 44,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Choose a delivery location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Set a deliverable address to see products available for your area.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => context.push('/location'),
                            child: const Text('Choose location'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(homeCategoriesProvider);
                      ref.invalidate(homeProductsProvider);

                      try {
                        await Future.wait([
                          ref.read(homeCategoriesProvider.future),
                          ref.read(homeProductsProvider.future),
                        ]);
                      } catch (_) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Could not refresh the home page. Please try again.',
                            ),
                          ),
                        );
                      }
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                      children: [
                        _buildHero(),
                        const SizedBox(height: 20),
                        _buildFreeDeliveryBanner(),
                        const SizedBox(height: 22),
                        _buildCategories(categories),
                        const SizedBox(height: 22),
                        _buildProducts(products),
                        const SizedBox(height: 22),
                        _buildStoreExperienceBanner(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: KMartBottomNav(
        currentIndex: _navIndex,
        onTap: (index) {
          if (index == 2 || index == 3) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  index == 2
                      ? 'Order history will be available in a later module.'
                      : 'Account management will be available in a later module.',
                ),
              ),
            );
            return;
          }
          if (index == 1) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CategoriesScreen()));
            return;
          }

          setState(() {
            _navIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        SizedBox(
          height: 205,
          child: PageView.builder(
            itemCount: _heroSlides.length,
            onPageChanged: (index) {
              setState(() {
                _heroIndex = index;
              });
            },
            itemBuilder: (_, index) {
              final slide = _heroSlides[index];

              return Container(
                padding: const EdgeInsets.fromLTRB(17, 16, 10, 14),
                decoration: BoxDecoration(
                  color: index.isEven
                      ? const Color(0xFFFBF6EE)
                      : const Color(0xFFF4FAF6),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE7E7E7)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slide.tag,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                              letterSpacing: .7,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            slide.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 21,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            slide.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              height: 1.35,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FilledButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ProductListingScreen(),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 34),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              slide.button,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: slide.image,
                          height: 170,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.white54),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _heroSlides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _heroIndex == index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _heroIndex == index
                    ? AppColors.primary
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFreeDeliveryBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF104A9E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.local_shipping_outlined, color: Colors.white, size: 34),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FREE DELIVERY OFFER',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFD166),
                    letterSpacing: .6,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'First 3 deliveries are free',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Valid on your first 3 orders according to your delivery settings.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, color: Color(0xFFDCEBFF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(AsyncValue<List<CategoryModel>> state) {
    return _Section(
      title: 'Shop by Category',
      child: state.when(
        loading: () => const SizedBox(
          height: 112,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => _DataError(
          message: 'Unable to load categories.',
          onRetry: () {
            ref.invalidate(homeCategoriesProvider);
          },
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const _EmptyData(
              icon: Icons.category_outlined,
              message: 'No categories available yet.',
            );
          }

          return SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final category = categories[index];

                return SizedBox(
                  width: 84,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CategoriesScreen(),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE1E5EA),
                              width: 1.5,
                            ),
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: _NetworkImage(
                              url: category.imageUrl,
                              icon: Icons.category_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          category.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProducts(AsyncValue<List<ProductModel>> state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "Today's Top Products",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProductListingScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        state.when(
          loading: () => const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => _DataError(
            message: 'Unable to load products from Supabase.',
            onRetry: () {
              ref.invalidate(homeProductsProvider);
            },
          ),
          data: (products) {
            if (products.isEmpty) {
              return const _EmptyData(
                icon: Icons.inventory_2_outlined,
                message: 'No products are available yet.',
              );
            }

            final visible = products.length > 6
                ? products.sublist(0, 6)
                : products;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visible.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: .67,
              ),
              itemBuilder: (_, index) {
                return _ProductCard(product: visible[index]);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStoreExperienceBanner() {
    return Container(
      height: 245,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/kmart_store.jpg', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.72),
                  Colors.black.withValues(alpha: 0.34),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.52, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 245),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'K MART STORE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Your K Mart,\nYour Everyday Store',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.08,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Quality products, great deals and convenient delivery from your local K Mart store.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 11),
                    const Row(
                      children: [
                        _StoreFeature(
                          icon: Icons.local_shipping_outlined,
                          label: 'Fast Delivery',
                        ),
                        SizedBox(width: 6),
                        _StoreFeature(
                          icon: Icons.verified_outlined,
                          label: 'Quality',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroData {
  const _HeroData(
    this.tag,
    this.title,
    this.description,
    this.button,
    this.image,
  );

  final String tag;
  final String title;
  final String description;
  final String button;
  final String image;
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _DataError extends StatelessWidget {
  const _DataError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: Colors.red, size: 30),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}

class _EmptyData extends StatelessWidget {
  const _EmptyData({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(height: 5),
          Text(
            message,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url, required this.icon});

  final String? url;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return Container(
        color: AppColors.background,
        child: Icon(icon, color: AppColors.primary, size: 28),
      );
    }

    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: AppColors.background,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.background,
        child: Icon(icon, color: AppColors.textSecondary, size: 28),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discount = product.discountPercent.round();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
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
                child: SizedBox(
                  width: double.infinity,
                  child: _NetworkImage(
                    url: product.imageUrl,
                    icon: Icons.image_outlined,
                  ),
                ),
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
                letterSpacing: .4,
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
                onPressed: () async {
                  final success = await ref
                      .read(cartProvider)
                      .addToCart(productId: product.id, quantity: 1);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? '${product.name} added to cart.' : 'Could not add this product. Check stock and sign-in, then try again.',
                      ),
                    ),
                  );
                },
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
      ),
    );
  }
}

class _StoreFeature extends StatelessWidget {
  const _StoreFeature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.navy),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}
