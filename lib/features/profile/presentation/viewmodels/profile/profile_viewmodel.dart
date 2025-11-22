import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/session/session_notifier.dart';
import 'package:sincro/features/auth/auth_providers.dart';
import 'package:sincro/features/profile/presentation/viewmodels/profile/profile_state.dart';
import 'package:sincro/features/profile/profile_providers.dart';

part 'profile_viewmodel.g.dart';

@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  ProfileState build() {
    return const ProfileState.initial();
  }

  Future<void> logout() async {
    ref.read(sessionProvider.notifier).setUnauthenticated();

    ref.read(authRepositoryProvider).logout().run();

    state = const ProfileState.initial();
  }

  Future<void> updateName(String newName) async {
    state = const ProfileState.loading();
    final repository = ref.read(profileRepositoryProvider);

    final result = await repository.updateName(newName).run();

    result.fold(
      (failure) => _setErrorState(failure),
      (updatedUser) {
        ref.read(sessionProvider.notifier).updateUser(updatedUser);
        state = const ProfileState.initial();
      },
    );
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    state = const ProfileState.loading();
    final repository = ref.read(profileRepositoryProvider);

    final result = await repository
        .updatePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
          newPasswordConfirmation: newPasswordConfirmation,
        )
        .run();

    result.fold(
      (failure) => _setErrorState(failure),
      (_) {
        state = const ProfileState.initial();
      },
    );
  }

  Future<void> updateFavoriteGroup(int? groupId) async {
    state = const ProfileState.loading();
    final repository = ref.read(profileRepositoryProvider);

    final result = await repository.updateFavoriteGroup(groupId).run();

    result.fold(
      (failure) => _setErrorState(failure),
      (updatedUser) {
        ref.read(sessionProvider.notifier).updateUser(updatedUser);
        state = const ProfileState.initial();
      },
    );
  }

  Future<List<dynamic>> getAvailableGroups() async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.getMyGroups().run();

    return result.getOrElse((_) => []);
  }

  void _setErrorState(AppFailure failure) {
    final message = switch (failure) {
      ValidationFailure(message: final msg) => msg,
      ServerFailure(message: final msg) => msg,
      _ => failure.message,
    };
    state = ProfileState.error(message);
  }
}
