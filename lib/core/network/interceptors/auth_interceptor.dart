import 'package:dio/dio.dart';
import 'package:sincro/core/constants/api_routes.dart';
import 'package:sincro/core/models/token_model.dart';
import 'package:sincro/core/models/user_model.dart';
import 'package:sincro/core/session/auth_event_notifier.dart';
import 'package:sincro/core/storage/hive_service.dart';
import 'package:sincro/core/storage/secure_storage_service.dart';
import 'package:sincro/core/utils/logger.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final HiveService _hiveService;
  final Dio _authDio;
  final AuthEventNotifier _eventNotifier;

  AuthInterceptor(
    this._storage,
    this._hiveService,
    this._authDio,
    this._eventNotifier,
  );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (ApiRoutes.publicEndpoints.any((path) => options.path.contains(path))) {
      return handler.next(options);
    }

    final result = await _storage.getTokens().run();

    result.fold(
      (failure) {
        log.e('Falha ao ler tokens do storage: ${failure.message}');
        handler.next(options);
      },
      (tokens) {
        if (tokens != null) {
          options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
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
        !err.requestOptions.path.contains(ApiRoutes.login) &&
        !err.requestOptions.path.contains(ApiRoutes.refreshToken)) {
      log.w('⚠️ 401 Detectado. Tentando refresh token...');

      final refreshResult = await _refreshToken();

      if (refreshResult) {
        log.i('🔄 Token renovado! Retentando requisição original...');

        final tokensResult = await _storage.getTokens().run();
        final tokens = tokensResult.getOrElse((_) => null);

        if (tokens != null) {
          err.requestOptions.headers['Authorization'] =
              'Bearer ${tokens.accessToken}';
        }

        try {
          final response = await _authDio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          log.e('❌ Falha ao retentar requisição: $e');
          return handler.next(err);
        }
      } else {
        log.e('❌ Falha no refresh token. Sessão expirada.');

        await _storage.deleteTokens().run();
        await _hiveService.deleteUser().run();

        _eventNotifier.emit(AuthEvent.forceLogout);
      }
    }
    super.onError(err, handler);
  }

  Future<bool> _refreshToken() async {
    final tokensResult = await _storage.getTokens().run();

    return tokensResult.fold((_) => false, (tokens) async {
      if (tokens == null) return false;

      try {
        final response = await _authDio.post(
          ApiRoutes.refreshToken,
          data: {'refresh_token': tokens.refreshToken},
        );

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;

          if (data['tokens'] != null) {
            final newTokens = TokenModel.fromJson(data['tokens']);
            await _storage.saveTokens(newTokens).run();
          }

          if (data['user'] != null) {
            final user = UserModel.fromJson(data['user']);
            await _hiveService.saveUser(user).run();
            log.i('👤 Cache de usuário atualizado via Refresh Token');
          }

          return true;
        }
        return false;
      } catch (e) {
        log.e('⛔ Erro no refresh: $e');
        return false;
      }
    });
  }
}
