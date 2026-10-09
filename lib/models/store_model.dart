class StoreModel {
  const StoreModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.serviceRadiusKm,
    required this.gofrugalAccountId,
    required this.active,
    this.createdAt,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double serviceRadiusKm;
  final String gofrugalAccountId;
  final bool active;
  final DateTime? createdAt;

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    double number(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }

      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return StoreModel(
      id: map['id'].toString(),
      name: (map['name'] ?? 'K Mart Store').toString(),
      address: (map['address'] ?? '').toString(),
      latitude: number(map['latitude']),
      longitude: number(map['longitude']),
      serviceRadiusKm: number(map['service_radius_km']),
      gofrugalAccountId:
          (map['gofrugal_account_id'] ?? '').toString(),
      active: map['active'] == true,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(
              map['created_at'].toString(),
            ),
    );
  }
}
