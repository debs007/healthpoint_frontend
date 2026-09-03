class CartItem {
  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.prescriptionRequired,
    this.unitPrice,
    this.lineTotal,
  });

  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final bool prescriptionRequired;
  // Nullable: the backend only resolves a price once the cart has a
  // franchise selected (see CartController::cartResponse - unit_price is
  // null when cart.franchise_id is null). Not an edge case to shrug off -
  // the UI needs to handle "no franchise chosen yet" as a real state.
  final double? unitPrice;
  final double? lineTotal;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      prescriptionRequired: json['prescription_required'] as bool? ?? false,
      unitPrice: json['unit_price'] != null ? double.tryParse(json['unit_price'].toString()) : null,
      lineTotal: json['line_total'] != null ? double.tryParse(json['line_total'].toString()) : null,
    );
  }
}
