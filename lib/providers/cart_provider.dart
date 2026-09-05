import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._cartService);

  final CartService _cartService;

  Cart cart = Cart.empty;
  bool isLoading = false;
  String? errorMessage;

  int get itemCount => cart.itemCount;

  Future<void> loadCart() async {
    isLoading = true;
    notifyListeners();

    try {
      cart = await _cartService.getCart();
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addItem(int productId, {int quantity = 1}) async {
    try {
      cart = await _cartService.addItem(productId, quantity);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    if (quantity < 1) {
      await removeItem(cartItemId);
      return;
    }
    cart = await _cartService.updateItem(cartItemId, quantity);
    notifyListeners();
  }

  Future<void> removeItem(int cartItemId) async {
    await _cartService.removeItem(cartItemId);
    await loadCart();
  }

  /// Selecting a franchise is what makes real prices appear - see Cart
  /// model's hasFranchiseSelected. Reloads afterward so unit_price/
  /// line_total switch from null to real numbers immediately.
  Future<bool> selectFranchise(int franchiseId) async {
    try {
      await _cartService.selectFranchise(franchiseId);
      await loadCart();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> applyCoupon(String code) async {
    try {
      cart = await _cartService.applyCoupon(code);
      errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> removeCoupon() async {
    cart = await _cartService.removeCoupon();
    notifyListeners();
  }
}
