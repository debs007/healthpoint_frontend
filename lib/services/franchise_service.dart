import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/franchise.dart';

class FranchiseService {
  FranchiseService(this._client);

  final ApiClient _client;

  Future<List<Franchise>> getFranchises({String? city, String? pincode}) async {
    final response = await _client.get(
      ApiEndpoints.franchises,
      query: {
        if (city != null && city.isNotEmpty) 'city': city,
        if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
      },
    );
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => Franchise.fromJson(e as Map<String, dynamic>)).toList();
  }
}
