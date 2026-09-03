import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  AuthStatus status = AuthStatus.unknown;
  User? currentUser;
  String? pendingMobile; // set once OTP is requested, used on the verify screen
  bool isLoading = false;
  String? errorMessage;

  /// Called once at app startup - checks for a saved token and, if
  /// present, confirms it's still valid against the server rather than
  /// just trusting it's still good.
  Future<void> checkAuthStatus() async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      currentUser = await _authService.getCurrentUser();
      status = AuthStatus.authenticated;
    } catch (_) {
      await SecureStorageService.clearAll();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> requestOtp(String mobile) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.requestOtp(mobile);
      pendingMobile = mobile;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String code) async {
    if (pendingMobile == null) {
      errorMessage = 'Session expired - request a new code.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await _authService.verifyOtp(pendingMobile!, code);
      status = AuthStatus.authenticated;
      pendingMobile = null;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Called by ApiClient.onUnauthorized when any request comes back 401 -
  /// forces the app back to the login flow regardless of which screen
  /// triggered it.
  void forceLogout() {
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? alternateMobile,
    String? imagePath,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await _authService.updateProfile(
        name: name,
        email: email,
        alternateMobile: alternateMobile,
        imagePath: imagePath,
      );
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    forceLogout();
  }
}
