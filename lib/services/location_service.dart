import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../models/store_model.dart';

class LocationSearchResult {
  const LocationSearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  final String displayName;
  final double latitude;
  final double longitude;
}

class NearestStoreResult {
  const NearestStoreResult({
    required this.store,
    required this.distanceKm,
    required this.isDeliverable,
  });

  final StoreModel store;
  final double distanceKm;
  final bool isDeliverable;
}

class LocationService {
  LocationService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;

  static const String _nominatimUrl =
      'https://nominatim.openstreetmap.org/search';

  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable location services and try again.',
      );
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Please enable it from your device settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  Future<List<LocationSearchResult>> searchLocation(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.length < 3) {
      return [];
    }

    final response = await _dio.get(
      _nominatimUrl,
      queryParameters: {
        'q': trimmedQuery,
        'format': 'jsonv2',
        'addressdetails': 1,
        'limit': 8,
        'countrycodes': 'in',
      },
      options: Options(headers: {'User-Agent': 'KMart Flutter App'}),
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map((item) {
          final latitude = double.tryParse(item['lat']?.toString() ?? '');

          final longitude = double.tryParse(item['lon']?.toString() ?? '');

          if (latitude == null || longitude == null) {
            return null;
          }

          return LocationSearchResult(
            displayName: (item['display_name'] ?? 'Selected location')
                .toString(),
            latitude: latitude,
            longitude: longitude,
          );
        })
        .whereType<LocationSearchResult>()
        .toList();
  }

  NearestStoreResult? findNearestStore({
    required double latitude,
    required double longitude,
    required List<StoreModel> stores,
  }) {
    if (stores.isEmpty) {
      return null;
    }

    StoreModel? nearestStore;
    double? nearestDistanceKm;

    for (final store in stores) {
      final distanceMeters = Geolocator.distanceBetween(
        latitude,
        longitude,
        store.latitude,
        store.longitude,
      );

      final distanceKm = distanceMeters / 1000;

      if (nearestDistanceKm == null || distanceKm < nearestDistanceKm) {
        nearestStore = store;
        nearestDistanceKm = distanceKm;
      }
    }

    if (nearestStore == null || nearestDistanceKm == null) {
      return null;
    }

    return NearestStoreResult(
      store: nearestStore,
      distanceKm: nearestDistanceKm,
      isDeliverable: nearestDistanceKm <= nearestStore.serviceRadiusKm,
    );
  }
}
