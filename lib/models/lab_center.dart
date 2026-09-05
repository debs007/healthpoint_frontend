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

  String get fullAddress => [address, city, state, pincode].where((s) => s != null && s.isNotEmpty).join(', ');

  factory LabCenter.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
