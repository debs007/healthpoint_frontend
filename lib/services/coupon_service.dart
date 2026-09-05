import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/coupon.dart';
import '../models/coupon_summary.dart';
import '../models/product.dart';

class CouponService {
  CouponService(this._client);

  final ApiClient _client;

  Future<List<CouponSummary>> getGlobalCoupons() async {
    final response = await _client.get(ApiEndpoints.coupons);
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => CouponSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<({Coupon coupon, List<Product> products})> getProducts(int couponId) async {
    final response = await _client.get(ApiEndpoints.couponProducts(couponId));
    final couponJson = response['coupon'] as Map<String, dynamic>;
    final productsJson = response['data'] as List<dynamic>? ?? [];

    return (
      coupon: Coupon.fromJson(couponJson),
      products: productsJson.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
