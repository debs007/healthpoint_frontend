import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/brand.dart';

class BrandService {
  BrandService(this._client);

  final ApiClient _client;

  Future<List<Brand>> getBrands() async {
    final response = await _client.get(ApiEndpoints.brands);
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => Brand.fromJson(e as Map<String, dynamic>)).toList();
  }
}
