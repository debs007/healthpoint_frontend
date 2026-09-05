import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/cart.dart';

class CartService {
  CartService(this._client);

  final ApiClient _client;

  /// The cart endpoints all return the full cart shape (not just an item
  /// list) - cart_id, franchise_id, requires_prescription, items, subtotal
  /// - confirmed against the real CartController, so every method here
  /// returns a full Cart rather than a bare item list.
  Future<Cart> getCart() async {
    final response = await _client.get(ApiEndpoints.cart);
    return Cart.fromJson(response);
  }

  Future<void> selectFranchise(int franchiseId) async {
    await _client.post(ApiEndpoints.cartSelectFranchise, data: {'franchise_id': franchiseId});
  }

  /// Throws ApiException (with the backend's real message - "invalid or
  /// expired", "doesn't apply to anything in your cart") on a bad code,
  /// same error-surfacing pattern as everywhere else in this app.
  Future<Cart> applyCoupon(String code) async {
    final response = await _client.post(ApiEndpoints.cartApplyCoupon, data: {'code': code});
    return Cart.fromJson(response);
  }

  Future<Cart> removeCoupon() async {
    final response = await _client.post(ApiEndpoints.cartRemoveCoupon);
    return Cart.fromJson(response);
  }

  Future<Cart> addItem(int productId, int quantity) async {
    final response = await _client.post(
      ApiEndpoints.cartItems,
      data: {'product_id': productId, 'quantity': quantity},
    );
    return Cart.fromJson(response);
  }

  Future<Cart> updateItem(int cartItemId, int quantity) async {
    final response = await _client.patch(ApiEndpoints.cartItem(cartItemId), data: {'quantity': quantity});
    return Cart.fromJson(response);
  }

  Future<void> removeItem(int cartItemId) async {
    await _client.delete(ApiEndpoints.cartItem(cartItemId));
  }
}
