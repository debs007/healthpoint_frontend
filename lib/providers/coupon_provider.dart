import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/coupon.dart';
import '../models/coupon_summary.dart';
import '../models/product.dart';
import '../services/coupon_service.dart';

class CouponProvider extends ChangeNotifier {
  CouponProvider(this._service);

  final CouponService _service;

  List<CouponSummary> globalCoupons = [];
  bool isLoadingGlobalCoupons = false;
  Coupon? coupon;
  List<Product> products = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadGlobalCoupons() async {
    isLoadingGlobalCoupons = true;
    notifyListeners();

    try {
      globalCoupons = await _service.getGlobalCoupons();
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoadingGlobalCoupons = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts(int couponId) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _service.getProducts(couponId);
      coupon = result.coupon;
      products = result.products;
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
