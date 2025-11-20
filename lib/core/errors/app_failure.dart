import 'package:dio/dio.dart';

abstract class AppFailure {
  final String message;
  const AppFailure({required this.message});
}

class GeneralFailure extends AppFailure {
  const GeneralFailure({required super.message});
}

class CacheFailure extends AppFailure {
  const CacheFailure({required super.message});
}

class ServerFailure extends AppFailure {
  const ServerFailure({required super.message});

  factory ServerFailure.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerFailure(
          message: 'Tempo de conexão esgotado. Verifique sua internet.',
        );

      case DioExceptionType.badResponse:
        final responseData = e.response?.data;
        final statusCode = e.response?.statusCode;

        if (statusCode == 422 && responseData is Map<String, dynamic>) {
          final message =
              responseData['message']?.toString() ?? 'Erro de validação';

          final errors =
              responseData['data']?['errors'] ?? responseData['errors'];

          return ValidationFailure(
            message: message,
            errors: errors is Map<String, dynamic> ? errors : null,
          );
        }

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data') &&
              responseData['data'] is Map<String, dynamic>) {
            final data = responseData['data'] as Map<String, dynamic>;
            if (data.containsKey('message')) {
              return ServerFailure(message: data['message'].toString());
            }
          }

          if (responseData.containsKey('message')) {
            return ServerFailure(message: responseData['message'].toString());
          }

          if (responseData.containsKey('error')) {
            return ServerFailure(message: responseData['error'].toString());
          }
        }

        if ((statusCode ?? 0) >= 500) {
          return const ServerFailure(
            message: 'Erro inesperado no servidor. Tente novamente mais tarde.',
          );
        }

        return ServerFailure(
          message:
              e.response?.statusMessage ?? 'Erro desconhecido no servidor.',
        );

      case DioExceptionType.cancel:
        return const ServerFailure(message: 'Requisição foi cancelada.');

      default:
        if (e.error != null && e.error.toString().contains('SocketException')) {
          return const ServerFailure(message: 'Sem conexão com a internet.');
        }
        return const ServerFailure(
          message: 'Erro de conexão. Verifique sua internet.',
        );
    }
  }
}

class ValidationFailure extends ServerFailure {
  final Map<String, dynamic>? errors;

  const ValidationFailure({
    required super.message,
    this.errors,
  });
}
