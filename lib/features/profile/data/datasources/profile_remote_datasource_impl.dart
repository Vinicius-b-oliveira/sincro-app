import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/constants/api_routes.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/user_model.dart';
import 'package:sincro/core/network/dio_client.dart';
import 'package:sincro/features/profile/data/datasources/profile_remote_datasource.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _client;

  ProfileRemoteDataSourceImpl(this._client);

  @override
  TaskEither<AppFailure, UserModel> updateProfile({
    required String name,
  }) {
    return _client
        .patch(
          ApiRoutes.userProfile,
          data: {'name': name},
        )
        .map((response) {
          return UserModel.fromJson(response.data);
        });
  }

  @override
  TaskEither<AppFailure, void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    return _client
        .patch(
          ApiRoutes.updatePassword,
          data: {
            'current_password': currentPassword,
            'new_password': newPassword,
            'new_password_confirmation': newPasswordConfirmation,
          },
        )
        .map((_) {});
  }

  @override
  TaskEither<AppFailure, UserModel> updatePreferences({
    required int? favoriteGroupId,
  }) {
    return _client
        .patch(
          ApiRoutes.userPreferences,
          data: {'favorite_group_id': favoriteGroupId},
        )
        .map((response) {
          return UserModel.fromJson(response.data);
        });
  }

  @override
  TaskEither<AppFailure, List<dynamic>> getGroups() {
    return _client.get('/groups').map((response) {
      final data = response.data;
      if (data is Map && data.containsKey('data') && data['data'] is List) {
        return data['data'] as List<dynamic>;
      }
      return [];
    });
  }
}
