class OrderItemLine {
  const OrderItemLine({
    required this.productName,
    required this.quantity,
    required this.totalPrice,
  });

  final String productName;
  final int quantity;
  final double totalPrice;

  factory OrderItemLine.fromJson(Map<String, dynamic> json) {
    return OrderItemLine(
      productName: json['product']?['name'] as String? ?? json['product_name'] as String? ?? '',
      quantity: json['quantity'] as int,
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0,
    );
  }
}

class LabTestBookingInfo {
  const LabTestBookingInfo({
    required this.testName,
    this.centerName,
    this.centerAddress,
    required this.bookingType,
    required this.scheduledDate,
    required this.status,
  });

  final String testName;
  final String? centerName;
  final String? centerAddress;
  final String bookingType;
  final DateTime scheduledDate;
  final String status;

  factory LabTestBookingInfo.fromJson(Map<String, dynamic> json) {
    return LabTestBookingInfo(
      testName: json['test_name'] as String? ?? '',
      centerName: json['center_name'] as String?,
      centerAddress: json['center_address'] as String?,
      bookingType: json['booking_type'] as String? ?? 'home_visit',
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      status: json['status'] as String? ?? 'pending',
    );
  }
}

class Order {
  const Order({
    required this.id,
    this.orderType = 'product',
    required this.status,
    required this.fulfillmentType,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.deliveryCharge,
    required this.totalAmount,
    required this.placedAt,
    this.franchiseName,
    this.items = const [],
    this.labTestBooking,
    this.confirmedAt,
    this.preparedAt,
    this.outForDeliveryAt,
    this.deliveredAt,
  });

  final int id;
  final String orderType; // 'product' or 'lab_test'
  final String status;
  final String fulfillmentType;
  // Confirmed against the real OrderResource - these are genuinely
  // separate fields, not derived from totalAmount. Previously this model
  // only captured totalAmount and silently dropped the rest.
  final double subtotalAmount;
  final double discountAmount;
  final double taxAmount;
  final double deliveryCharge;
  final double totalAmount;
  final DateTime placedAt;
  final String? franchiseName;
  final List<OrderItemLine> items;
  // Populated only when orderType is 'lab_test' - the equivalent of
  // items for a product order. This is what was missing before: the
  // order existed and could be paid for, but nothing showed what test
  // was actually booked.
  final LabTestBookingInfo? labTestBooking;
  final DateTime? confirmedAt;
  final DateTime? preparedAt;
  final DateTime? outForDeliveryAt;
  final DateTime? deliveredAt;

  /// Matches the web portal's convention - a business-friendly order
  /// number rather than a raw database id.
  String get displayId => 'HP${id.toString().padLeft(7, '0')}';

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final labTestBookingJson = json['lab_test_booking'] as Map<String, dynamic>?;

    DateTime? parseNullable(String? key) =>
        json[key] != null ? DateTime.tryParse(json[key].toString()) : null;

    return Order(
      id: json['id'] as int,
      orderType: json['order_type'] as String? ?? 'product',
      status: json['status'] as String,
      fulfillmentType: json['fulfillment_type'] as String,
      subtotalAmount: double.tryParse(json['subtotal_amount']?.toString() ?? '') ?? 0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '') ?? 0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '') ?? 0,
      deliveryCharge: double.tryParse(json['delivery_charge']?.toString() ?? '') ?? 0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0,
      placedAt: DateTime.parse((json['placed_at'] ?? json['created_at']) as String),
      franchiseName: json['franchise']?['name'] as String?,
      items: itemsJson.map((e) => OrderItemLine.fromJson(e as Map<String, dynamic>)).toList(),
      labTestBooking: labTestBookingJson != null ? LabTestBookingInfo.fromJson(labTestBookingJson) : null,
      confirmedAt: parseNullable('confirmed_at'),
      preparedAt: parseNullable('prepared_at'),
      outForDeliveryAt: parseNullable('out_for_delivery_at'),
      deliveredAt: parseNullable('delivered_at'),
    );
  }
}
