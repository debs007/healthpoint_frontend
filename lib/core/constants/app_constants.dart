/// App-wide constants. Change the app name, tagline, or API URLs here -
/// nowhere else in the codebase should hardcode these values directly.
class AppConstants {
  AppConstants._();

  // --- Identity ---
  static const String appName = 'Susthayan';
  static const String appTagline = 'Your Health, Our Priority';

  // --- API ---
  // Swap baseUrl for your actual environment. Kept as a single source of
  // truth rather than scattered through every service file - see
  // ApiClient in core/network/api_client.dart, which is the only other
  // place this gets read.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://susthayan.online/api',
  );

  static const Duration apiTimeout = Duration(seconds: 20);

  // --- OTP ---
  static const int otpLength = 6;
  static const Duration otpResendCooldown = Duration(seconds: 30);

  // --- Storage keys ---
  // Centralized so a typo in one place can't silently create a second,
  // disconnected storage entry.
  static const String storageKeyAuthToken = 'health_point_auth_token';
  static const String storageKeyUserId = 'health_point_user_id';

  // --- Misc ---
  static const String currencySymbol = '₹';
  static const int defaultPageSize = 20;
}
