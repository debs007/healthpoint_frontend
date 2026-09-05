import 'cart_item.dart';

class AppliedCoupon {
  const AppliedCoupon({required this.id, required this.code, required this.discountAmount});

  final int id;
  final String code;
  final double discountAmount;

  factory AppliedCoupon.fromJson(Map<String, dynamic> json) {
    return AppliedCoupon(
      id: json['id'] as int,
      code: json['code'] as String,
      discountAmount: double.tryParse(json['discount_amount'].toString()) ?? 0,
    );
  }
}

class Cart {
  const Cart({
    required this.cartId,
    this.franchiseId,
    required this.requiresPrescription,
    required this.items,
    required this.subtotal,
    this.coupon,
    required this.total,
  });

  final int cartId;
  final int? franchiseId;
  final bool requiresPrescription;
  final List<CartItem> items;
  final double subtotal;
  final AppliedCoupon? coupon;
  final double total;

  bool get hasFranchiseSelected => franchiseId != null;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final couponJson = json['coupon'] as Map<String, dynamic>?;
    final subtotal = double.tryParse(json['subtotal'].toString()) ?? 0;

    return Cart(
      cartId: json['cart_id'] as int,
      franchiseId: json['franchise_id'] as int?,
      requiresPrescription: json['requires_prescription'] as bool? ?? false,
      items: itemsJson.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList(),
      subtotal: subtotal,
      coupon: couponJson != null ? AppliedCoupon.fromJson(couponJson) : null,
      // Falls back to subtotal (no discount) if the backend response is
      // from before this field existed, rather than crashing on a null.
      total: json['total'] != null ? double.tryParse(json['total'].toString()) ?? subtotal : subtotal,
    );
  }

  static const empty = Cart(cartId: 0, requiresPrescription: false, items: [], subtotal: 0, total: 0);
}
