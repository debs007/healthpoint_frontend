import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/home_banner.dart';
import '../services/home_banner_service.dart';

class HomeBannerProvider extends ChangeNotifier {
  HomeBannerProvider(this._service);

  final HomeBannerService _service;

  List<HomeBanner> banners = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadBanners() async {
    if (banners.isNotEmpty) return; // shared across Home + Categories - load once, both screens reuse the same result
    isLoading = true;
    notifyListeners();

    try {
      banners = await _service.getBanners();
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
