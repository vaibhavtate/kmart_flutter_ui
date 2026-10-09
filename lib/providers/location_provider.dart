import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../models/store_model.dart';
import '../repositories/store_repository.dart';
import '../services/location_service.dart';

final storeRepositoryProvider = Provider<StoreRepository>(
  (ref) => StoreRepository(),
);

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

final locationProvider =
    NotifierProvider<LocationController, LocationState>(
  LocationController.new,
);

class LocationState {
  const LocationState({
    this.isLoading = false,
    this.isSearching = false,
    this.searchResults = const [],
    this.selectedAddress,
    this.latitude,
    this.longitude,
    this.selectedStore,
    this.distanceKm,
    this.isDeliverable = false,
    this.error,
  });

  final bool isLoading;
  final bool isSearching;

  final List<LocationSearchResult> searchResults;

  final String? selectedAddress;
  final double? latitude;
  final double? longitude;

  final StoreModel? selectedStore;
  final double? distanceKm;
  final bool isDeliverable;

  final String? error;

  LocationState copyWith({
    bool? isLoading,
    bool? isSearching,
    List<LocationSearchResult>? searchResults,
    String? selectedAddress,
    double? latitude,
    double? longitude,
    StoreModel? selectedStore,
    double? distanceKm,
    bool? isDeliverable,
    String? error,
    bool clearError = false,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      searchResults:
          searchResults ?? this.searchResults,
      selectedAddress:
          selectedAddress ?? this.selectedAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      selectedStore:
          selectedStore ?? this.selectedStore,
      distanceKm:
          distanceKm ?? this.distanceKm,
      isDeliverable:
          isDeliverable ?? this.isDeliverable,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class LocationController
    extends Notifier<LocationState> {
  late final LocationService _locationService;
  late final StoreRepository _storeRepository;

  @override
  LocationState build() {
    _locationService =
        ref.read(locationServiceProvider);

    _storeRepository =
        ref.read(storeRepositoryProvider);

    return const LocationState();
  }

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.length < 3) {
      state = state.copyWith(
        searchResults: const [],
        isSearching: false,
        clearError: true,
      );
      return;
    }

    state = state.copyWith(
      isSearching: true,
      clearError: true,
    );

    try {
      final results =
          await _locationService.searchLocation(
        trimmedQuery,
      );

      state = state.copyWith(
        isSearching: false,
        searchResults: results,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        searchResults: const [],
        error:
            'Unable to search this location. Please try again.',
      );
    }
  }

  Future<void> useCurrentLocation() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final position =
          await _locationService.getCurrentPosition();

      await selectLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: 'Current location',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _friendlyLocationError(e),
      );
    }
  }

  Future<void> selectSearchResult(
    LocationSearchResult result,
  ) async {
    await selectLocation(
      latitude: result.latitude,
      longitude: result.longitude,
      address: result.displayName,
    );
  }

  Future<void> selectLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final stores =
          await _storeRepository.getActiveStores();

      if (stores.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          selectedAddress: address,
          latitude: latitude,
          longitude: longitude,
          error:
              'K Mart delivery is currently unavailable because no active store is available.',
        );
        return;
      }

      final nearest =
          _locationService.findNearestStore(
        latitude: latitude,
        longitude: longitude,
        stores: stores,
      );

      if (nearest == null) {
        state = state.copyWith(
          isLoading: false,
          selectedAddress: address,
          latitude: latitude,
          longitude: longitude,
          error:
              'We could not find a K Mart store near this location.',
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        selectedAddress: address,
        latitude: latitude,
        longitude: longitude,
        selectedStore: nearest.store,
        distanceKm: nearest.distanceKm,
        isDeliverable: nearest.isDeliverable,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Unable to check K Mart delivery availability. Please try again.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }

  String _friendlyLocationError(Object error) {
    final message = error.toString();

    if (message.contains(
      'Location services are disabled',
    )) {
      return 'Location services are disabled. Please enable them and try again.';
    }

    if (message.contains(
      'permission was denied',
    )) {
      return 'Location permission was denied. Please allow location access to continue.';
    }

    if (message.contains(
      'permanently denied',
    )) {
      return 'Location permission is permanently denied. Please enable it from device settings.';
    }

    return 'Unable to get your current location. Please try again.';
  }
}