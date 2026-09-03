import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._orderService);

  final OrderService _orderService;

  List<Order> orders = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadOrders() async {
    isLoading = true;
    notifyListeners();

    try {
      orders = await _orderService.getOrders();
      // Most recent first - the backend already orders this way, but
      // don't depend on that silently holding true forever.
      orders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Order> filteredByStatus(String? status) {
    if (status == null) return orders;
    return orders.where((o) => o.status == status).toList();
  }

  /// Single-order fetch, deliberately separate from the list state above -
  /// a detail screen shouldn't have to wait for or mutate the shared
  /// orders list just to show one order.
  Future<Order> getOrderDetail(int id) => _orderService.getOrder(id);

  Future<Order> placeOrder({
    required int franchiseId,
    required String fulfillmentType,
    int? addressId,
  }) =>
      _orderService.placeOrder(franchiseId: franchiseId, fulfillmentType: fulfillmentType, addressId: addressId);

  Future<Map<String, dynamic>> initiatePayment(int orderId) => _orderService.initiatePayment(orderId);

  Future<Order> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) =>
      _orderService.verifyPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );
}
