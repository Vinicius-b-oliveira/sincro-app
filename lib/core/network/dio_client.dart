import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../errors/app_failure.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio);

  AppFailure _handleError(Object error, StackTrace stack) {
    if (error is DioException) {
      return ServerFailure.fromDioException(error);
    }
    return GeneralFailure(message: error.toString());
  }

  TaskEither<AppFailure, Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return TaskEither.tryCatch(
      () => _dio.get(path, queryParameters: queryParameters),
      _handleError,
    );
  }

  TaskEither<AppFailure, Response> post(
    String path, {
    dynamic data,
  }) {
    return TaskEither.tryCatch(
      () => _dio.post(path, data: data),
      _handleError,
    );
  }

  TaskEither<AppFailure, Response> put(
    String path, {
    dynamic data,
  }) {
    return TaskEither.tryCatch(
      () => _dio.put(path, data: data),
      _handleError,
    );
  }

  TaskEither<AppFailure, Response> patch(
    String path, {
    dynamic data,
  }) {
    return TaskEither.tryCatch(
      () => _dio.patch(path, data: data),
      _handleError,
    );
  }

  TaskEither<AppFailure, Response> delete(
    String path, {
    dynamic data,
  }) {
    return TaskEither.tryCatch(
      () => _dio.delete(path, data: data),
      _handleError,
    );
  }

  TaskEither<AppFailure, Response> download(
    String urlPath,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) {
    return TaskEither.tryCatch(
      () => _dio.download(
        urlPath,
        savePath,
        queryParameters: queryParameters,
        data: data,
      ),
      _handleError,
    );
  }
}
