class Franchise {
  const Franchise({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.phone,
  });

  final int id;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? phone;

  String get locationLabel => [city, state].where((s) => s != null && s.isNotEmpty).join(', ');

  factory Franchise.fromJson(Map<String, dynamic> json) {
    return Franchise(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      phone: json['phone'] as String?,
    );
  }
}
