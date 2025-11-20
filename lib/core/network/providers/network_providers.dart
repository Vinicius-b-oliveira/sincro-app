import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/config/api_config.dart';
import 'package:sincro/core/network/dio_client.dart';
import 'package:sincro/core/network/interceptors/auth_interceptor.dart';
import 'package:sincro/core/network/interceptors/logging_interceptor.dart';
import 'package:sincro/core/storage/storage_providers.dart';

part 'network_providers.g.dart';

@Riverpod(keepAlive: true)
Dio authDio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(ref.watch(loggingInterceptorProvider));
  }

  return dio;
}

// 2. Interceptor de Auth - Recebe o Dio Limpo
@Riverpod(keepAlive: true)
AuthInterceptor authInterceptor(Ref ref) {
  return AuthInterceptor(
    ref.watch(secureStorageServiceProvider),
    ref.watch(authDioProvider),
  );
}

// 3. Dio Principal - Usado pela aplicação
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // Adiciona AuthInterceptor E Logging
  dio.interceptors.add(ref.watch(authInterceptorProvider));

  if (kDebugMode) {
    dio.interceptors.add(ref.watch(loggingInterceptorProvider));
  }

  return dio;
}

// 4. Cliente HTTP Abstraído (TaskEither)
@Riverpod(keepAlive: true)
DioClient dioClient(Ref ref) {
  return DioClient(ref.watch(dioProvider));
}
