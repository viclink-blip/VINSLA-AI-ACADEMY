import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Singleton Dio client with JWT injection + auto-refresh
class ApiClient {
  static ApiClient? _instance;
  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  ApiClient._() {
    dio = Dio(BaseOptions(
      baseUrl:        AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers:        {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: AppConstants.kAccessToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Try refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            final token = await _storage.read(key: AppConstants.kAccessToken);
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $token';
            final response = await dio.fetch(opts);
            handler.resolve(response);
            return;
          }
        }
        handler.next(error);
      },
    ));
  }

  static ApiClient get instance => _instance ??= ApiClient._();

  Future<bool> _refreshToken() async {
    try {
      final refresh = await _storage.read(key: AppConstants.kRefreshToken);
      if (refresh == null) return false;
      final res = await dio.post('/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $refresh'}));
      final newToken = res.data['data']['access_token'];
      await _storage.write(key: AppConstants.kAccessToken, value: newToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: AppConstants.kAccessToken, value: access);
    await _storage.write(key: AppConstants.kRefreshToken, value: refresh);
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
