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
  bool isLoading = false;
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
    } finally {
      isLoading = false;
      notifyListeners();
    }
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

  /// Single-product fetch, same pattern as OrderProvider.getOrderDetail() -
  /// screens that need one product shouldn't have to construct their own
  /// ProductService or wait on the shared products list.
  Future<Product> getProduct(int id) => _productService.getProduct(id);
}
