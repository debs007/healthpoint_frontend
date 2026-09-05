import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._productService);

  final ProductService _productService;

  List<Product> products = [];
  List<Category> categories = [];
  Map<int, List<Product>> latestByCategory = {};
  bool isLoading = false;
  bool isLoadingCategoryRows = false;
  String? errorMessage;

  Future<void> loadHomeData() async {
    isLoading = true;
    notifyListeners();

    try {
      products = await _productService.getProducts();
      categories = await _productService.getCategories();
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      // Anything else - still needs to leave Home in a safe, recoverable
      // state rather than propagate uncaught.
      errorMessage = 'Something went wrong loading the home page.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// One row per category on Home, newest products first. Runs the
  /// per-category fetches in parallel rather than one after another, and
  /// only once per app session - categories rarely change mid-session, so
  /// there's no value in re-fetching every time Home rebuilds.
  Future<void> loadCategoryRows() async {
    if (latestByCategory.isNotEmpty || categories.isEmpty) return;

    isLoadingCategoryRows = true;
    notifyListeners();

    // Each category's fetch is caught on its own, catching any error (not
    // just ApiException) - one category with a malformed product
    // shouldn't be able to blank out every other category's row too.
    // Future.wait alone couldn't provide that: it fails the whole batch
    // the moment any single future throws.
    final results = await Future.wait(
      categories.map((c) async {
        try {
          return MapEntry(c.id, await _productService.getLatestByCategory(c.id));
        } catch (_) {
          return MapEntry(c.id, <Product>[]);
        }
      }),
    );
    latestByCategory = Map.fromEntries(results.where((e) => e.value.isNotEmpty));

    isLoadingCategoryRows = false;
    notifyListeners();
  }

  Future<List<Product>> search(String query) async {
    try {
      return await _productService.getProducts(query: query);
    } on ApiException {
      return [];
    }
  }

  Future<List<Product>> byCategory(int categoryId) async {
    try {
      return await _productService.getProducts(categoryId: categoryId);
    } on ApiException {
      return [];
    }
  }

  Future<List<Product>> byBrand(int brandId) async {
    try {
      return await _productService.getProducts(brandId: brandId);
    } on ApiException {
      return [];
    }
  }

  /// Single-product fetch, same pattern as OrderProvider.getOrderDetail() -
  /// screens that need one product shouldn't have to construct their own
  /// ProductService or wait on the shared products list.
  Future<Product> getProduct(int id) => _productService.getProduct(id);
}
