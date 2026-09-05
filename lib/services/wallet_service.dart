import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/order.dart';
import '../models/wallet.dart';

class WalletService {
  WalletService(this._client);

  final ApiClient _client;

  Future<Wallet> getWallet() async {
    final response = await _client.get(ApiEndpoints.wallet);
    return Wallet.fromJson(response);
  }

  /// Returns a real Order - the caller hands this straight to the
  /// existing initiatePayment()/verifyPayment() flow, same as every
  /// other "this costs money" feature in this app. The wallet balance
  /// only actually increases once that payment succeeds server-side.
  Future<Order> topup(double amount) async {
    final response = await _client.post(ApiEndpoints.walletTopup, data: {'amount': amount});
    return Order.fromJson(response['data'] as Map<String, dynamic>? ?? response);
  }
}
