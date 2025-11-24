import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/config/api_config.dart';
import 'package:sincro/core/network/dio_client.dart';
import 'package:sincro/core/network/interceptors/auth_interceptor.dart';
import 'package:sincro/core/network/interceptors/laravel_response_interceptor.dart';
import 'package:sincro/core/network/interceptors/logging_interceptor.dart';
import 'package:sincro/core/storage/storage_providers.dart';

part 'network_providers.g.dart';

@Riverpod(keepAlive: true)
LoggingInterceptor loggingInterceptor(Ref ref) {
  return LoggingInterceptor();
}

@Riverpod(keepAlive: true)
LaravelResponseInterceptor laravelResponseInterceptor(
  Ref ref,
) {
  return LaravelResponseInterceptor();
}

@Riverpod(keepAlive: true)
AuthInterceptor authInterceptor(Ref ref) {
  return AuthInterceptor(
    ref.watch(secureStorageServiceProvider),
    ref.watch(hiveServiceProvider),
    ref.watch(authDioProvider),
  );
}

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

  dio.interceptors.add(ref.watch(laravelResponseInterceptorProvider));

  if (kDebugMode) {
    dio.interceptors.add(ref.watch(loggingInterceptorProvider));
  }

  return dio;
}

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

  dio.interceptors.add(ref.watch(authInterceptorProvider));
  dio.interceptors.add(ref.watch(laravelResponseInterceptorProvider));

  if (kDebugMode) {
    dio.interceptors.add(ref.watch(loggingInterceptorProvider));
  }

  return dio;
}

@Riverpod(keepAlive: true)
DioClient dioClient(Ref ref) {
  return DioClient(ref.watch(dioProvider));
}
