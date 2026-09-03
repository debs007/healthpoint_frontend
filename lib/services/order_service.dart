import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/order.dart';

class OrderService {
  OrderService(this._client);

  final ApiClient _client;

  Future<List<Order>> getOrders() async {
    final response = await _client.get(ApiEndpoints.orders);
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Order> getOrder(int id) async {
    final response = await _client.get(ApiEndpoints.order(id));
    return Order.fromJson(response['data'] as Map<String, dynamic>? ?? response);
  }

  /// Field names match the verified PlaceOrderRequest exactly:
  /// franchise_id (required), fulfillment_type (required, delivery|pickup),
  /// address_id (required only when fulfillment_type is delivery).
  Future<Order> placeOrder({
    required int franchiseId,
    required String fulfillmentType,
    int? addressId,
  }) async {
    final response = await _client.post(
      ApiEndpoints.orders,
      data: {
        'franchise_id': franchiseId,
        'fulfillment_type': fulfillmentType,
        if (addressId != null) 'address_id': addressId,
      },
    );
    return Order.fromJson(response['order'] as Map<String, dynamic>? ?? response['data'] as Map<String, dynamic>? ?? response);
  }

  /// Returns the raw initiate response - {payment_id, gateway_order_id,
  /// key, amount, currency} - verified directly against PaymentController.
  Future<Map<String, dynamic>> initiatePayment(int orderId) async {
    return _client.post(ApiEndpoints.initiatePayment(orderId));
  }

  /// Field names match exactly what Razorpay's checkout SDK hands back in
  /// its success callback (razorpay_order_id/payment_id/signature) and
  /// what the backend's verify() validates - confirmed against the real
  /// PaymentController, not assumed from Razorpay's generic docs.
  Future<Order> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await _client.post(
      ApiEndpoints.verifyPayment,
      data: {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
    );
    return Order.fromJson(response['order'] as Map<String, dynamic>);
  }
}
