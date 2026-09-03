import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/home_banner.dart';

class HomeBannerService {
  HomeBannerService(this._client);

  final ApiClient _client;

  Future<List<HomeBanner>> getBanners() async {
    final response = await _client.get(ApiEndpoints.homeBanners);
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => HomeBanner.fromJson(e as Map<String, dynamic>)).toList();
  }
}
