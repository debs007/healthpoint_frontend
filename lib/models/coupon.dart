class Coupon {
  const Coupon({
    required this.id,
    required this.code,
    this.description,
    required this.discountType,
    required this.discountValue,
  });

  final int id;
  final String code;
  final String? description;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;

  String get discountLabel => discountType == 'percentage'
      ? '${discountValue.toStringAsFixed(0)}% OFF'
      : '₹${discountValue.toStringAsFixed(0)} OFF';

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as int,
      code: json['code'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String,
      discountValue: double.tryParse(json['discount_value'].toString()) ?? 0,
    );
  }
}
