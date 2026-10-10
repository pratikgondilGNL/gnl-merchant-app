import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/services/token_storage.dart';
import '../../routing/app_router.dart';
import '../../routing/app_routes.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient(AppStorage storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(storage),
      _LogInterceptor(),
    ]);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.delete<T>(path, queryParameters: queryParameters, options: options);
}

class _AuthInterceptor extends Interceptor {
  final AppStorage _storage;

  _AuthInterceptor(this._storage);

  bool _isRedirecting = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !_isAuthEndpoint(err.requestOptions.path)) {
      await _handleUnauthorized();
    }
    handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    final cleanPath = path.split('?').first;
    return cleanPath == ApiEndpoints.login ||
        cleanPath == ApiEndpoints.signUp ||
        cleanPath == ApiEndpoints.verifyOtp ||
        cleanPath == ApiEndpoints.resendOtp;
  }

  Future<void> _handleUnauthorized() async {
    if (_isRedirecting) return;
    _isRedirecting = true;
    try {
      await _storage.clearAll();
      AppRouter.router.goNamed(AppRoutes.login);
    } catch (e) {
      debugPrint('[API] Session cleanup failed: $e');
    } finally {
      _isRedirecting = false;
    }
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[API REQUEST] ${options.method} ${options.uri}');
    debugPrint('[TOKEN] ${options.headers}');
    log('[API REQUEST BODY] ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[API RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('[API RESPONSE DATA] ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    debugPrint('[API ERROR] ${error.type} ${error.requestOptions.uri}');
    debugPrint('[API ERROR MESSAGE] ${error.message}');
    if (error.response != null) {
      debugPrint('[API ERROR RESPONSE] ${error.response?.data}');
    }
    handler.next(error);
  }
}
