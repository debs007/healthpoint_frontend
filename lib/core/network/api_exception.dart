import 'package:dio/dio.dart';

/// Normalizes every way the Laravel backend can report an error into one
/// shape. Laravel validation failures look like
/// {"message": "...", "errors": {"field": ["msg"]}}; hand-thrown
/// exceptions in the app's own controllers look like {"message": "..."}
/// with no errors key. Screens should only ever need [message].
class ApiException implements Exception {
  ApiException({required this.message, this.fieldErrors, this.statusCode});

  final String message;
  final Map<String, List<String>>? fieldErrors;
  final int? statusCode;

  factory ApiException.fromDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Can\'t reach Susthayan right now - check your connection and try again.',
        statusCode: statusCode,
      );
    }

    if (data is Map<String, dynamic>) {
      final message = data['message'] as String? ?? 'Something went wrong. Please try again.';
      final rawErrors = data['errors'];
      Map<String, List<String>>? fieldErrors;

      if (rawErrors is Map<String, dynamic>) {
        fieldErrors = rawErrors.map(
          (key, value) => MapEntry(key, (value as List).map((e) => e.toString()).toList()),
        );
      }

      return ApiException(message: message, fieldErrors: fieldErrors, statusCode: statusCode);
    }

    return ApiException(
      message: 'Something went wrong. Please try again.',
      statusCode: statusCode,
    );
  }

  /// The first field-specific error, if any - convenient for showing a
  /// single message without a screen needing to know the field structure.
  String? get firstFieldError => fieldErrors?.values.firstOrNull?.firstOrNull;
}
