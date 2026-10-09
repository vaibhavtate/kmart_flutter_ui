
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.mrp,
    required this.sellingPrice,
    this.taxPercent,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    this.active = true,
    this.stockQuantity,
  });

  final String id;
  final String name;
  final double mrp;
  final double sellingPrice;
  final double? taxPercent;
  final String? imageUrl;
  final String? categoryId;
  final String? categoryName;
  final bool active;
  final double? stockQuantity;

  double get discountPercent {
    if (mrp <= 0 || sellingPrice >= mrp) return 0;
    return ((mrp - sellingPrice) / mrp) * 100;
  }

  bool get hasDiscount => discountPercent > 0.5;

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    double number(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse('$value') ?? 0;
    }

    return ProductModel(
      id: '${map['id']}',
      name: (map['name'] ?? map['title'] ?? 'Product').toString(),
      mrp: number(map['mrp']),
      sellingPrice: number(
        map['selling_price'] ?? map['price'] ?? map['sellingPrice'],
      ),
      taxPercent: map['tax_percent'] == null
          ? null
          : number(map['tax_percent']),
      imageUrl: map['image_url']?.toString(),
      categoryId: map['category_id']?.toString(),
      categoryName: map['category_name']?.toString(),
      active: map['active'] != false,
      stockQuantity: map['stock_quantity'] == null
          ? null
          : number(map['stock_quantity']),
    );
  }
}
