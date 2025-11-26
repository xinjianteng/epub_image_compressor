/// API 响应包装
class ApiResponse<T> {
  ApiResponse({
    required this.success,
    this.data,
    this.message = '',
    this.statusCode,
  });

  final bool success;
  final T? data;
  final String message;
  final int? statusCode;
}

class ApiException implements Exception {
  ApiException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => 'ApiException(code: $code, message: $message)';
}
