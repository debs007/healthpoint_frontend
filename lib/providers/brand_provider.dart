import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/brand.dart';
import '../services/brand_service.dart';

class BrandProvider extends ChangeNotifier {
  BrandProvider(this._brandService);

  final BrandService _brandService;

  List<Brand> brands = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadBrands() async {
    isLoading = true;
    notifyListeners();

    try {
      brands = await _brandService.getBrands();
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
