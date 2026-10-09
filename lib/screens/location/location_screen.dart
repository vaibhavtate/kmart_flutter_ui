import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/location_provider.dart';
import '../../services/location_service.dart';

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    FocusScope.of(context).unfocus();
    ref.read(locationProvider.notifier).search(value);
  }

  Future<void> _useCurrentLocation() async {
    await ref.read(locationProvider.notifier).useCurrentLocation();

    if (!mounted) return;

    final state = ref.read(locationProvider);

    if (state.isDeliverable) {
      _showSuccessAndContinue();
    }
  }

  Future<void> _selectResult(LocationSearchResult result) async {
    FocusScope.of(context).unfocus();

    await ref.read(locationProvider.notifier).selectSearchResult(result);

    if (!mounted) return;

    final state = ref.read(locationProvider);

    if (state.isDeliverable) {
      _showSuccessAndContinue();
    }
  }

  void _showSuccessAndContinue() {
    final state = ref.read(locationProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Delivery available from ${state.selectedStore?.name ?? 'K Mart'}.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery Location'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Where should we deliver?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose your delivery location to see whether K Mart is available in your area.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _searchController,
                onSubmitted: _submitSearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Enter a location and press Search',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: state.isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Press Search on your keyboard to find matching places.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),

              if (state.searchResults.isNotEmpty) ...[
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: state.searchResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final result = state.searchResults[index];

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFEAF7EE),
                          child: Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          result.displayName,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _selectResult(result),
                      );
                    },
                  ),
                ),
              ] else ...[
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: state.isLoading ? null : _useCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use my current location'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (state.isLoading)
                  const Center(child: CircularProgressIndicator()),

                if (state.error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorCard(message: state.error!),
                ],

                if (state.selectedStore != null && !state.isLoading) ...[
                  const SizedBox(height: 16),
                  _StoreAvailabilityCard(state: state),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreAvailabilityCard extends StatelessWidget {
  const _StoreAvailabilityCard({required this.state});

  final LocationState state;

  @override
  Widget build(BuildContext context) {
    final store = state.selectedStore;

    if (store == null) {
      return const SizedBox.shrink();
    }

    final distance = state.distanceKm?.toStringAsFixed(1) ?? '-';

    if (!state.isDeliverable) {
      return _ErrorCard(
        message:
            'Sorry, K Mart does not currently deliver to this location. '
            '${store.name} is approximately $distance km away.',
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Delivery available',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            store.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            store.address,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            '$distance km from selected location',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
