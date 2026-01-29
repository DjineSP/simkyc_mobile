import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../services/storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  late Dio dio;

  static const _kUserTokenKey = 'user_token';

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
      ),
    );

    // On peut ajouter un logger pour voir les requêtes dans la console
    dio.interceptors.add(LogInterceptor(responseBody: true));
  }
}