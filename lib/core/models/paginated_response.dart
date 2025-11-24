import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_response.freezed.dart';
part 'paginated_response.g.dart';

@Freezed(genericArgumentFactories: true)
abstract class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    required List<T> data,
    @JsonKey(name: 'meta') required MetaData meta,
  }) = _PaginatedResponse;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);
}

@freezed
abstract class MetaData with _$MetaData {
  const factory MetaData({
    @JsonKey(name: 'current_page') required int currentPage,
    @JsonKey(name: 'last_page') required int lastPage,
    @JsonKey(name: 'per_page') required int perPage,
    @JsonKey(name: 'total') required int total,
  }) = _MetaData;

  factory MetaData.fromJson(Map<String, dynamic> json) =>
      _$MetaDataFromJson(json);
}
