import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/health_article.dart';

class HealthArticleService {
  HealthArticleService(this._client);

  final ApiClient _client;

  Future<List<HealthArticle>> getArticles() async {
    final response = await _client.get(ApiEndpoints.healthArticles);
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => HealthArticle.fromJson(e as Map<String, dynamic>)).toList();
  }
}
