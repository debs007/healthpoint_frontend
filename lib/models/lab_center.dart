class LabCenter {
  const LabCenter({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.state,
    this.pincode,
    this.phone,
    required this.offersHomeCollection,
    this.price,
    this.totalPrice,
    this.testPrices = const {},
  });

  final int id;
  final String name;
  final String address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? phone;
  final bool offersHomeCollection;
  // Only populated when this center was fetched in the context of a
  // specific test (via GET /lab-tests/{id}/centers) - the price is
  // specific to a center+test pair, not a property of the center alone.
  final double? price;
  // Only populated by the multi-test centers endpoint - every selected
  // test's price at this center, summed. testPrices holds the same data
  // broken out per test id, for a line-by-line display if needed.
  final double? totalPrice;
  final Map<int, double> testPrices;

  String get fullAddress => [address, city, state, pincode].where((s) => s != null && s.isNotEmpty).join(', ');

  factory LabCenter.fromJson(Map<String, dynamic> json) {
    final testPricesJson = json['test_prices'] as List<dynamic>? ?? [];
    return LabCenter(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      phone: json['phone'] as String?,
      offersHomeCollection: json['offers_home_collection'] as bool? ?? false,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      totalPrice: json['total_price'] != null ? double.tryParse(json['total_price'].toString()) : null,
      testPrices: {
        for (final entry in testPricesJson)
          (entry as Map<String, dynamic>)['lab_test_id'] as int: double.tryParse(entry['price'].toString()) ?? 0,
      },
    );
  }
}
