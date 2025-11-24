import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  TaskEither<AppFailure, UserModel> updateProfile({
    required String name,
  });

  TaskEither<AppFailure, void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  TaskEither<AppFailure, UserModel> updatePreferences({
    required int? favoriteGroupId,
  });

  TaskEither<AppFailure, List<GroupModel>> getGroups();
}
