class Category {
  const Category({required this.id, required this.name, this.productCount});

  final int id;
  final String name;
  final int? productCount;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      productCount: json['product_count'] as int?,
    );
  }
}
