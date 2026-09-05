import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/order.dart';
import '../models/wallet.dart';
import '../services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  WalletProvider(this._service);

  final WalletService _service;

  Wallet wallet = Wallet.empty;
  bool isLoading = false;
  bool isToppingUp = false;
  String? errorMessage;

  Future<void> loadWallet() async {
    isLoading = true;
    notifyListeners();

    try {
      wallet = await _service.getWallet();
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> topup(double amount) async {
    isToppingUp = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await _service.topup(amount);
    } on ApiException catch (e) {
      errorMessage = e.message;
      return null;
    } finally {
      isToppingUp = false;
      notifyListeners();
    }
  }
}
