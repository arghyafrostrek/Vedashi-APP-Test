import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

/// Core API client with Dio interceptors for:
/// - Auto-attach Bearer token
/// - Handle 401 with auto-logout
/// - Global error handling
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Callback to trigger logout from providers
  Function? onUnauthorized;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(_authInterceptor());
    dio.interceptors.add(_errorInterceptor());
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[API] $obj'),
    ));
  }

  /// Auth interceptor: attaches Bearer token to every request
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Try to refresh the token
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            // Retry the original request
            try {
              final token = await _storage.read(key: 'access_token');
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $token';
              final response = await dio.fetch(opts);
              return handler.resolve(response);
            } catch (e) {
              // Refresh failed, force logout
              await _forceLogout();
              return handler.next(error);
            }
          } else {
            await _forceLogout();
          }
        }
        handler.next(error);
      },
    );
  }

  /// Error interceptor: global error handling
  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        String message = 'Something went wrong';
        if (error.response?.data is Map) {
          message = error.response?.data['message'] ?? message;
        } else if (error.type == DioExceptionType.connectionTimeout) {
          message = 'Connection timed out';
        } else if (error.type == DioExceptionType.receiveTimeout) {
          message = 'Server took too long to respond';
        } else if (error.type == DioExceptionType.connectionError) {
          message = 'No internet connection';
        }
        // Attach parsed message to error
        error = error.copyWith(
          error: message,
        );
        handler.next(error);
      },
    );
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      // Use a clean Dio instance to avoid interceptor loops
      final freshDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await freshDio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        await _storage.write(key: 'access_token', value: data['access_token']);
        await _storage.write(key: 'refresh_token', value: data['refresh_token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _forceLogout() async {
    await _storage.deleteAll();
    onUnauthorized?.call();
  }

  // ─── Convenience Methods ────────────────────────────────────

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return dio.patch(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) {
    return dio.delete(path, data: data);
  }
}
