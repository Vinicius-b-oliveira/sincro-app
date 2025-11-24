import 'dart:convert';

import 'package:dio/dio.dart';

import '../../utils/logger.dart';

class LoggingInterceptor extends Interceptor {
  final bool logDetailed;

  LoggingInterceptor({this.logDetailed = false});

  static const Set<String> _sensitiveKeys = {
    'password',
    'password_confirmation',
    'current_password',
    'new_password',
    'new_password_confirmation',
    'token',
    'access_token',
    'refresh_token',
    'authorization',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final logMsg = StringBuffer();

    logMsg.writeln('🌍 REQUEST [${options.method}] => PATH: ${options.path}');

    if (logDetailed) {
      logMsg.writeln('📋 HEADERS: ${_prettyPrint(_maskData(options.headers))}');

      if (options.data != null) {
        if (options.data is FormData) {
          logMsg.writeln('📦 BODY (FormData): [Arquivos/Campos Ocultos]');
        } else {
          logMsg.writeln('📦 BODY: ${_prettyPrint(_maskData(options.data))}');
        }
      }

      if (options.queryParameters.isNotEmpty) {
        logMsg.writeln(
          '🔍 QUERY PARAMS: ${_prettyPrint(_maskData(options.queryParameters))}',
        );
      }
    }

    log.i(logMsg.toString());
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final logMsg = StringBuffer();

    logMsg.writeln(
      '✅ RESPONSE [${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );

    if (logDetailed && response.data != null) {
      logMsg.writeln(
        '📦 RESPONSE BODY: ${_prettyPrint(_maskData(response.data))}',
      );
    }

    log.i(logMsg.toString());
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
            errorDetails = _prettyPrint(innerData['errors']);
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

    if (logDetailed && response?.data != null) {
      logMsg.writeln(
        '📦 ERROR BODY: ${_prettyPrint(_maskData(response?.data))}',
      );
    }

    log.e(logMsg.toString());
    super.onError(err, handler);
  }

  String _prettyPrint(dynamic data) {
    try {
      if (data is String) return data;
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  dynamic _maskData(dynamic data) {
    if (data is Map<String, dynamic>) {
      final newData = Map<String, dynamic>.from(data);
      newData.forEach((key, value) {
        if (_sensitiveKeys.any((s) => key.toLowerCase().contains(s))) {
          newData[key] = '********';
        } else {
          newData[key] = _maskData(value);
        }
      });
      return newData;
    } else if (data is List) {
      return data.map((e) => _maskData(e)).toList();
    } else if (data is Map) {
      final newData = Map.from(data);
      newData.forEach((key, value) {
        if (key is String &&
            _sensitiveKeys.any((s) => key.toLowerCase().contains(s))) {
          newData[key] = '********';
        } else {
          newData[key] = _maskData(value);
        }
      });
      return newData;
    }
    return data;
  }
}
