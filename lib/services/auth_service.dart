import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/user.dart';

class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  Future<void> requestOtp(String mobile) async {
    await _client.post(ApiEndpoints.otpRequest, data: {'mobile': mobile});
  }

  /// Verifies the OTP and persists the returned token - callers don't
  /// need to separately save it. Returns is_new_user alongside the user
  /// so the caller can decide whether to show the complete-profile step.
  Future<(User, bool)> verifyOtp(String mobile, String code) async {
    final response = await _client.post(
      ApiEndpoints.otpVerify,
      data: {'mobile': mobile, 'code': code},
    );

    final token = response['token'] as String;
    final userJson = response['user'] as Map<String, dynamic>;
    final user = User.fromJson(userJson);
    final isNewUser = response['is_new_user'] as bool? ?? false;

    await SecureStorageService.saveToken(token);
    await SecureStorageService.saveUserId(user.id);

    return (user, isNewUser);
  }

  Future<User> getCurrentUser() async {
    final response = await _client.get(ApiEndpoints.me);
    return User.fromJson(response['user'] as Map<String, dynamic>? ?? response);
  }

  /// imagePath is optional - a profile update might just change the name
  /// or email with no new photo, matching the backend's
  /// UpdateProfileRequest (profile_image is nullable there too).
  Future<User> updateProfile({
    String? name,
    String? email,
    String? alternateMobile,
    String? imagePath,
    String? dob,
    String? gender,
  }) async {
    final fields = {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (alternateMobile != null) 'alternate_mobile': alternateMobile,
      if (dob != null) 'dob': dob,
      if (gender != null) 'gender': gender,
    };

    final response = imagePath != null
        ? await _client.uploadFile(
            ApiEndpoints.updateProfile,
            filePath: imagePath,
            fieldName: 'profile_image',
            extraFields: fields,
            method: 'PATCH',
          )
        : await _client.patch(ApiEndpoints.updateProfile, data: fields);

    return User.fromJson(response['user'] as Map<String, dynamic>? ?? response);
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } finally {
      // Clear locally regardless of whether the server call succeeded -
      // a failed logout request shouldn't leave someone stuck logged in
      // on the device.
      await SecureStorageService.clearAll();
    }
  }
}
