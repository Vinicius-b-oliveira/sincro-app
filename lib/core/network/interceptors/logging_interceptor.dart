import 'package:dio/dio.dart';

import '../../utils/logger.dart';

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
    final response = err.response;
    String errorMsg = err.message ?? 'Erro desconhecido';
    String? errorDetails;

    if (response?.data != null) {
      final data = response!.data;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is Map) {
          final innerData = data['data'] as Map<String, dynamic>;

          if (innerData.containsKey('message')) {
            errorMsg = innerData['message'].toString();
          }

          if (innerData.containsKey('errors')) {
            errorDetails = innerData['errors'].toString();
          }
        } else if (data.containsKey('message')) {
          errorMsg = data['message'].toString();
        } else if (data.containsKey('error')) {
          errorMsg = data['error'].toString();
        }
      }
    }

    final logMsg = StringBuffer()
      ..writeln(
        '❌ ERROR [${response?.statusCode}] => PATH: ${err.requestOptions.path}',
      )
      ..writeln('⛔ MSG: $errorMsg');

    if (errorDetails != null) {
      logMsg.writeln('🔍 DETAILS: $errorDetails');
    }

    log.e(logMsg.toString());
    super.onError(err, handler);
  }
}
