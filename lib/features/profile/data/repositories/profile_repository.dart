import 'package:fpdart/fpdart.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/user_model.dart';

abstract class ProfileRepository {
  TaskEither<AppFailure, UserModel> updateName(String newName);

  TaskEither<AppFailure, void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  TaskEither<AppFailure, UserModel> updateFavoriteGroup(int? groupId);

  TaskEither<AppFailure, List<dynamic>> getMyGroups();
}
