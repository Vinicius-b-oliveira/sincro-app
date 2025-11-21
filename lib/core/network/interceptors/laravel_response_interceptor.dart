import 'package:dio/dio.dart';
import 'package:sincro/core/utils/logger.dart';

class LaravelResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final hasDataKey = data.containsKey('data');
      final hasPagination =
          data.containsKey('meta') || data.containsKey('links');

      if (hasDataKey && !hasPagination) {
        if (data['data'] != null) {
          log.d('📦 Desenvelopando resposta Laravel (Recurso Simples)');
          response.data = data['data'];
        }
      } else if (hasPagination) {
        log.d('📄 Mantendo estrutura de Paginação Laravel');
      }
    }

    super.onResponse(response, handler);
  }
}
