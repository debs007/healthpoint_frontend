class CouponSummary {
  const CouponSummary({
    required this.id,
    required this.code,
    this.description,
    required this.discountType,
    required this.discountValue,
    required this.productCount,
  });

  final int id;
  final String code;
  final String? description;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final int productCount;

  String get discountLabel => discountType == 'percentage'
      ? '${discountValue.toStringAsFixed(0)}% OFF'
      : '₹${discountValue.toStringAsFixed(0)} OFF';

  factory CouponSummary.fromJson(Map<String, dynamic> json) {
    return CouponSummary(
      id: json['id'] as int,
      code: json['code'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String,
      discountValue: double.tryParse(json['discount_value'].toString()) ?? 0,
      productCount: json['product_count'] as int? ?? 0,
    );
  }
}
