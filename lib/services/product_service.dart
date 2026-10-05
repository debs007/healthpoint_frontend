import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/category.dart';
import '../models/product.dart';

class ProductService {
  ProductService(this._client);

  final ApiClient _client;

  Future<List<Product>> getProducts({String? query, int? categoryId, int? brandId}) async {
    final response = await _client.get(
      ApiEndpoints.products,
      query: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (categoryId != null) 'category_id': categoryId,
        if (brandId != null) 'brand_id': brandId,
      },
    );

    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Product> getProduct(int id) async {
    final response = await _client.get(ApiEndpoints.product(id));
    return Product.fromJson(response['data'] as Map<String, dynamic>? ?? response);
  }

  /// Newest-first, for a category's horizontal row on Home - "try to
  /// fetch the latest added products" from the request, not just
  /// whatever the default alphabetical listing happens to return.
  Future<List<Product>> getLatestByCategory(int categoryId, {int limit = 20}) async {
    final response = await _client.get(
      ApiEndpoints.products,
      query: {'category_id': categoryId, 'sort': 'latest', 'per_page': limit},
    );
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// The real GET /customer/categories endpoint - every active category,
  /// independent of which products happen to be on any given page.
  /// Previously this derived a category list from a single page of
  /// getProducts() results instead, which only ever discovered whichever
  /// categories that one page's products happened to belong to - a
  /// category with few/no products among that page (or simply listed
  /// later) never showed up at all, regardless of whether it actually
  /// existed or had other products elsewhere.
  Future<List<Category>> getCategories() async {
    final response = await _client.get(ApiEndpoints.categories);
    final data = response['categories'] as List? ?? [];
    return data.map((c) => Category.fromJson(c as Map<String, dynamic>)).toList();
  }
}
