import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;

  AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path.contains('/login') || options.path.contains('/register')) {
      return handler.next(options);
    }

    final tokenResult = await _storage.read('access_token').run();

    tokenResult.fold(
      (failure) => handler.next(options),
      (token) {
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    );
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains(ApiConstants.refresh)) {
      final refreshResult = await _refreshToken();

      if (refreshResult) {
        final opts = err.requestOptions;
        final newTokenResult = await _storage.read('access_token').run();

        newTokenResult.map(
          (token) => opts.headers['Authorization'] = 'Bearer $token',
        );

        try {
          final response = await _dio.fetch(opts);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      }
    }

    return handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshTokenResult = await _storage.read('refresh_token').run();

    return refreshTokenResult.fold(
      (_) => false,
      (refreshToken) async {
        if (refreshToken == null) return false;

        try {
          final tempDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

          final response = await tempDio.post(
            ApiConstants.refresh,
            data: {'refresh_token': refreshToken},
            options: Options(
              headers: {
                'Authorization': 'Bearer $refreshToken',
                'Accept': 'application/json',
              },
            ),
          );

          if (response.statusCode == 200) {
            final data = response.data;
            if (data['tokens'] != null) {
              final newAccess = data['tokens']['access_token'];
              final newRefresh = data['tokens']['refresh_token'];

              await _storage.write('access_token', newAccess).run();
              await _storage.write('refresh_token', newRefresh).run();
              return true;
            }
          }
          return false;
        } catch (e) {
          await _storage.deleteAll().run();
          return false;
        }
      },
    );
  }
}
