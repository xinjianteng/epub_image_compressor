import 'package:get/get.dart';

import '/api/api_config.dart';
import '/api/api_response.dart';
import '/service/oauth_service.dart';
import '/utils/logger.dart';

/// 基于 GetConnect 的轻量客户端：负责 Token 注入、日志输出与响应包装。
class ApiClient extends GetConnect {
  ApiClient() {
    httpClient
      ..baseUrl = ApiConfig.baseUrl
      ..timeout = const Duration(milliseconds: ApiConfig.connectTimeoutMs)
      ..maxAuthRetries = 0
      ..timeout = const Duration(milliseconds: ApiConfig.receiveTimeoutMs)
      ..addRequestModifier<Object?>((request) {
        final token = _token;
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        return request;
      })
      ..addResponseModifier((request, response) {
        Logger().info(
          'HTTP ${response.statusCode} ${request.url}',
          tag: 'http',
        );
        return response;
      });
  }

  String? get _token {
    if (Get.isRegistered<OauthService>()) {
      return Get.find<OauthService>().oauth.value.access_token;
    }
    return null;
  }

  /// GET 请求
  Future<ApiResponse<T>> getJson<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final res = await get(path, query: query);
      return _wrapResponse(res, decoder);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// POST 请求
  Future<ApiResponse<T>> postJson<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final res = await post(path, body, query: query);
      return _wrapResponse(res, decoder);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ApiResponse<T> _wrapResponse<T>(
    Response<dynamic> res,
    T Function(dynamic data)? decoder,
  ) {
    final statusCode = res.statusCode ?? 0;
    final bool success = statusCode >= 200 && statusCode < 300;
    final body = res.body;
    final T? parsed = decoder != null ? decoder(body) : body as T?;
    return ApiResponse<T>(
      success: success,
      data: parsed,
      message: success ? '' : '请求失败($statusCode)',
      statusCode: statusCode,
    );
  }
}
