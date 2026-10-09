class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.slug,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? slug;
  final String? imageUrl;

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: '${map['id']}',
      name: (map['name'] ?? map['title'] ?? 'Category').toString(),
      slug: map['slug']?.toString(),
      imageUrl: map['image_url']?.toString(),
    );
  }
}
