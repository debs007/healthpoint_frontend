import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/address.dart';

class AddressService {
  AddressService(this._client);

  final ApiClient _client;

  Future<List<Address>> getAddresses() async {
    final response = await _client.get(ApiEndpoints.addresses);
    final data = response['addresses'] as List<dynamic>? ?? [];
    return data.map((e) => Address.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Address> addAddress({
    String? label,
    required String line1,
    String? line2,
    required String city,
    required String state,
    required String pincode,
    bool isDefault = false,
  }) async {
    final response = await _client.post(
      ApiEndpoints.addresses,
      data: {
        if (label != null && label.isNotEmpty) 'label': label,
        'line1': line1,
        if (line2 != null && line2.isNotEmpty) 'line2': line2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'is_default': isDefault,
      },
    );
    return Address.fromJson(response['address'] as Map<String, dynamic>);
  }

  Future<void> deleteAddress(int id) async {
    await _client.delete(ApiEndpoints.address(id));
  }
}
