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

        if ((e.response?.statusCode ?? 0) >= 500) {
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

      case DioExceptionType.unknown:
        if (e.error != null && e.error.toString().contains('SocketException')) {
          return const ServerFailure(message: 'Sem conexão com a internet.');
        }
        return const ServerFailure(
          message: 'Erro desconhecido. Tente novamente.',
        );

      default:
        return const ServerFailure(
          message: 'Erro de conexão. Verifique sua internet.',
        );
    }
  }
}
