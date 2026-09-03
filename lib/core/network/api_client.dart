import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

/// Single Dio instance for the whole app. Every service (AuthService,
/// ProductService, etc.) takes this in its constructor rather than
/// creating its own Dio - one place to configure base URL, timeouts,
/// auth headers, and 401 handling.
class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token is invalid/expired - clear it and let onUnauthorized
            // (wired up to AuthProvider in main.dart) send the user back
            // to login. Deliberately not doing navigation from inside the
            // network layer directly - keeps this class independent of
            // any BuildContext/router.
            SecureStorageService.clearAll();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  Dio get dio => _dio;

  /// Set by main.dart at startup - called whenever a request comes back
  /// 401, regardless of which screen triggered it.
  void Function()? onUnauthorized;

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get(path, queryParameters: query);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Added for HealthService.updateProfile() - the backend route for that
  /// is genuinely Route::put(...), not patch, so this needed to exist as
  /// its own method rather than reusing patch() and creating a verb
  /// mismatch with the server.
  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Multipart upload - used for prescription images.
  Future<Map<String, dynamic>> uploadFile(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? extraFields,
    String method = 'POST',
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?extraFields,
        fieldName: await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.request(
        path,
        data: formData,
        options: Options(method: method),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
