import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Wraps flutter_secure_storage - Keychain on iOS, EncryptedSharedPreferences
/// on Android. Nothing else in the app should touch secure storage
/// directly; go through this so the storage keys stay centralized in
/// AppConstants instead of duplicated string literals.
class SecureStorageService {
  SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.storageKeyAuthToken, value: token);

  static Future<String?> getToken() =>
      _storage.read(key: AppConstants.storageKeyAuthToken);

  static Future<void> saveUserId(int userId) =>
      _storage.write(key: AppConstants.storageKeyUserId, value: userId.toString());

  static Future<int?> getUserId() async {
    final value = await _storage.read(key: AppConstants.storageKeyUserId);
    return value != null ? int.tryParse(value) : null;
  }

  /// Called on logout - clears everything this app stored, not just the token.
  static Future<void> clearAll() => _storage.deleteAll();
}
