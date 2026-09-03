import 'cart_item.dart';

class Cart {
  const Cart({
    required this.cartId,
    this.franchiseId,
    required this.requiresPrescription,
    required this.items,
    required this.subtotal,
  });

  final int cartId;
  final int? franchiseId;
  final bool requiresPrescription;
  final List<CartItem> items;
  final double subtotal;

  bool get hasFranchiseSelected => franchiseId != null;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    return Cart(
      cartId: json['cart_id'] as int,
      franchiseId: json['franchise_id'] as int?,
      requiresPrescription: json['requires_prescription'] as bool? ?? false,
      items: itemsJson.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList(),
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
    );
  }

  static const empty = Cart(cartId: 0, requiresPrescription: false, items: [], subtotal: 0);
}
