import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../errors/app_failure.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio);

  TaskEither<AppFailure, Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return TaskEither.tryCatch(
      () => _dio.get(path, queryParameters: queryParameters),
      (error, stack) => ServerFailure.fromDioException(error as DioException),
    );
  }

  TaskEither<AppFailure, Response> post(
    String path, {
    dynamic data,
  }) {
    return TaskEither.tryCatch(
      () => _dio.post(path, data: data),
      (error, stack) => ServerFailure.fromDioException(error as DioException),
    );
  }

  TaskEither<AppFailure, Response> put(
    String path, {
    dynamic data,
  }) {
    return TaskEither.tryCatch(
      () => _dio.put(path, data: data),
      (error, stack) => ServerFailure.fromDioException(error as DioException),
    );
  }

  TaskEither<AppFailure, Response> patch(
    String path, {
    dynamic data,
  }) {
    return TaskEither.tryCatch(
      () => _dio.patch(path, data: data),
      (error, stack) => ServerFailure.fromDioException(error as DioException),
    );
  }

  TaskEither<AppFailure, Response> delete(
    String path, {
    dynamic data,
  }) {
    return TaskEither.tryCatch(
      () => _dio.delete(path, data: data),
      (error, stack) => ServerFailure.fromDioException(error as DioException),
    );
  }
}
