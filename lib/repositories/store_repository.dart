import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/store_model.dart';

class StoreRepository {
  StoreRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Returns all active K Mart stores from the existing stores table.
  ///
  /// This performs a READ only.
  Future<List<StoreModel>> getActiveStores() async {
    final response = await _client
        .from('stores')
        .select()
        .eq('active', true)
        .order('name');

    return (response as List)
        .map(
          (item) => StoreModel.fromMap(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  /// Finds the nearest active store to the supplied coordinates.
  ///
  /// Distance/radius calculation is intentionally handled by
  /// LocationService, not by the database.
  Future<List<StoreModel>> getStores() async {
    final response = await _client.from('stores').select().order('name');

    return (response as List)
        .map(
          (item) => StoreModel.fromMap(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
