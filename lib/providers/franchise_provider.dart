import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/franchise.dart';
import '../services/franchise_service.dart';

class FranchiseProvider extends ChangeNotifier {
  FranchiseProvider(this._franchiseService);

  final FranchiseService _franchiseService;

  List<Franchise> franchises = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadFranchises() async {
    isLoading = true;
    notifyListeners();

    try {
      franchises = await _franchiseService.getFranchises();
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
