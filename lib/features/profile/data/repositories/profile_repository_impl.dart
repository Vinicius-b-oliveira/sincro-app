import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/user_model.dart';
import 'package:sincro/core/storage/hive_service.dart';
import 'package:sincro/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:sincro/features/profile/data/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final HiveService _hiveService;

  ProfileRepositoryImpl(this._remoteDataSource, this._hiveService);

  @override
  TaskEither<AppFailure, UserModel> updateName(String newName) {
    return _remoteDataSource
        .updateProfile(
          name: newName,
        )
        .flatMap((user) {
          return _hiveService.saveUser(user).map((_) => user);
        });
  }

  @override
  TaskEither<AppFailure, void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    return _remoteDataSource.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }

  @override
  TaskEither<AppFailure, UserModel> updateFavoriteGroup(int? groupId) {
    return _remoteDataSource
        .updatePreferences(favoriteGroupId: groupId)
        .flatMap((user) {
          return _hiveService.saveUser(user).map((_) => user);
        });
  }
}
