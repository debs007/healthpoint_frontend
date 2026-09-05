class Product {
  const Product({
    required this.id,
    required this.name,
    this.slug,
    this.manufacturer,
    this.saltComposition,
    this.description,
    this.drugSchedule,
    this.imageUrl,
    this.unit,
    required this.prescriptionRequired,
    this.mrp,
    this.sellingPrice,
    this.availableStock,
    this.categoryId,
    this.categoryName,
    this.couponPrice,
  });

  final int id;
  final String name;
  final String? slug;
  final String? manufacturer;
  final String? saltComposition;
  final String? description;
  final String? drugSchedule;
  final String? imageUrl;
  final String? unit;
  final bool prescriptionRequired;
  final double? mrp;
  final double? sellingPrice;
  final int? availableStock;
  final int? categoryId;
  final String? categoryName;
  // Only ever populated when this Product came from the coupon products
  // endpoint (GET /coupons/{id}/products) - null everywhere else.
  final double? couponPrice;

  bool get inStock => (availableStock ?? 0) > 0;

  bool get hasDiscount => mrp != null && sellingPrice != null && sellingPrice! < mrp!;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((mrp! - sellingPrice!) / mrp!) * 100).round();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Confirmed directly against the real ProductResource - the key is
    // 'price' (nested mrp/selling_price), not 'resolved_price', and
    // 'available_stock' at the top level, not 'resolved_stock'. Both were
    // wrong in this model before - genuinely never caught, since nothing
    // in this build has run against live backend data until now.
    final price = json['price'] as Map<String, dynamic>?;
    // category is a plain string (the name only) whenever the backend's
    // whenLoaded('category', ...) actually has a category to report -
    // never a nested {id, name} object. Casting it straight to a Map
    // threw immediately for any product with a category attached, which
    // silently crashed every product fetch (an uncaught exception in an
    // async callback doesn't show an error - it just leaves the provider
    // stuck in its empty starting state).
    final categoryName = json['category'] is String ? json['category'] as String : null;

    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      manufacturer: json['manufacturer'] as String?,
      saltComposition: json['salt_composition'] as String?,
      description: json['description'] as String?,
      drugSchedule: json['drug_schedule'] as String?,
      imageUrl: json['image_url'] as String?,
      unit: json['unit'] as String?,
      prescriptionRequired: json['prescription_required'] as bool? ?? false,
      mrp: price != null ? double.tryParse(price['mrp'].toString()) : null,
      sellingPrice: price != null ? double.tryParse(price['selling_price'].toString()) : null,
      availableStock: json['available_stock'] as int?,
      categoryId: json['category_id'] as int?,
      categoryName: categoryName,
      couponPrice: json['coupon_price'] != null ? double.tryParse(json['coupon_price'].toString()) : null,
    );
  }
}
