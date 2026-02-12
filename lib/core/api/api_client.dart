import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  late Dio dio;

  static const _kUserTokenKey = 'user_token';
  static const _kRefreshTokenKey = 'user_refresh_token';

  // Callback to trigger logout from outside (e.g. main.dart)
  static VoidCallback? onSessionExpired;

  bool _isRefreshing = false;
  List<Map<String, dynamic>> _failedRequests = [];

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BACKEND_BASE_URL'] ?? 'https://api.oufarez.com/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['requiresAuth'] == false) {
            return handler.next(options); 
          }

          final token = await StorageService.instance.secureRead(_kUserTokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == 401) {
            final options = error.requestOptions;

             // Check if already refreshing
            if (_isRefreshing) {
              // Create a completer to wait for refresh
               final resolver = Completer<Response>();
               _failedRequests.add({
                 'options': options,
                 'resolver': resolver,
                 'handler': handler,
               });
               return; // Do not reject yet, wait for refresh
            }

            _isRefreshing = true;

            try {
              final newTokens = await _refreshToken();
              if (newTokens != null) {
                // Update Storage
                await StorageService.instance.secureWrite(_kUserTokenKey, newTokens['accessToken']);
                await StorageService.instance.secureWrite(_kRefreshTokenKey, newTokens['refreshToken']);
                
                // Retry original request
                options.headers['Authorization'] = 'Bearer ${newTokens['accessToken']}';
                
                // Process queued requests
                _processFailedRequests(newTokens['accessToken']);
                
                final response = await dio.fetch(options);
                return handler.resolve(response);
              } else {
                 _processFailedRequests(null);
                 onSessionExpired?.call();
                 return handler.next(error);
              }
            } catch (e) {
              _processFailedRequests(null);
               onSessionExpired?.call();
               return handler.next(error);
            } finally {
              _isRefreshing = false;
            }
          }
          return handler.next(error);
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  Future<Map<String, dynamic>?> _refreshToken() async {
    try {
      final refreshToken = await StorageService.instance.secureRead(_kRefreshTokenKey);
      if (refreshToken == null) return null;

      // Use a new Dio instance to avoid interceptor loop or just use correct options
      // But creating new Dio is safer to avoid any global interceptor interference if we add more
      final refreshDio = Dio(BaseOptions(
        baseUrl: dio.options.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await refreshDio.post(
        '/api/Login/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final tokenData = response.data['token_Data'];
        return {
          'accessToken': tokenData['accessToken'],
          'refreshToken': tokenData['refreshToken'],
        };
      }
    } catch (e) {
      // Refresh failed
    }
    return null;
  }

  void _processFailedRequests(String? newToken) {
    for (var request in _failedRequests) {
      final handler = request['handler'] as ErrorInterceptorHandler;
      final options = request['options'] as RequestOptions;
      
      if (newToken != null) {
         options.headers['Authorization'] = 'Bearer $newToken';
         dio.fetch(options).then((response) {
           handler.resolve(response);
         }).catchError((e) {
           handler.reject(e);
         });
      } else {
         handler.reject(DioException(requestOptions: options, error: 'Session expired'));
      }
    }
    _failedRequests.clear();
  }
}