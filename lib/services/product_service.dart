import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/category.dart';
import '../models/product.dart';

class ProductService {
  ProductService(this._client);

  final ApiClient _client;

  Future<List<Product>> getProducts({String? query, int? categoryId}) async {
    final response = await _client.get(
      ApiEndpoints.products,
      query: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (categoryId != null) 'category_id': categoryId,
      },
    );

    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Product> getProduct(int id) async {
    final response = await _client.get(ApiEndpoints.product(id));
    return Product.fromJson(response['data'] as Map<String, dynamic>? ?? response);
  }

  /// Categories aren't behind their own endpoint on the customer side yet
  /// (only Admin manages/lists them) - a real GET /customer/categories
  /// would be the correct fix. This derives a category list from whatever
  /// names are actually present on returned products, so it never shows
  /// a fabricated label - a product with no category name attached is
  /// just left out rather than guessed at. Count is a genuine tally of
  /// products sharing that category_id, not a placeholder number.
  Future<List<Category>> getCategories() async {
    final products = await getProducts();
    final names = <int, String>{};
    final counts = <int, int>{};

    for (final product in products) {
      if (product.categoryId != null && product.categoryName != null) {
        names[product.categoryId!] = product.categoryName!;
        counts[product.categoryId!] = (counts[product.categoryId!] ?? 0) + 1;
      }
    }

    return names.entries
        .map((e) => Category(id: e.key, name: e.value, productCount: counts[e.key]))
        .toList();
  }
}
