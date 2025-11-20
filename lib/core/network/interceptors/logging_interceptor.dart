import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../utils/logger.dart';

part 'logging_interceptor.g.dart';

@riverpod
LoggingInterceptor loggingInterceptor(Ref ref) {
  return LoggingInterceptor();
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log.i('🌍 REQUEST [${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log.i(
      '✅ RESPONSE [${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log.e(
      '❌ ERROR [${err.response?.statusCode}] => PATH: ${err.requestOptions.path}\nMSG: ${err.message}',
    );
    super.onError(err, handler);
  }
}
