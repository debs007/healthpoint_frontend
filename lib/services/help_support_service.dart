import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/support_query.dart';

class HelpSupportService {
  HelpSupportService(this._client);

  final ApiClient _client;

  Future<List<SupportQuery>> getMyQueries() async {
    final response = await _client.get(ApiEndpoints.supportQueries);
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => SupportQuery.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SupportQuery> submitQuery({required String subject, required String message}) async {
    final response = await _client.post(
      ApiEndpoints.supportQueries,
      data: {'subject': subject, 'message': message},
    );
    return SupportQuery.fromJson(response['data'] as Map<String, dynamic>);
  }
}
