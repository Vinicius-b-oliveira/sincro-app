import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/session/session_notifier.dart';
import 'package:sincro/features/auth/auth_providers.dart';
import 'package:sincro/features/auth/presentation/viewmodels/login/login_state.dart';

part 'login_viewmodel.g.dart';

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginState build() {
    return const LoginState.initial();
  }

  Future<void> login(String email, String password) async {
    state = const LoginState.loading();

    final repository = ref.read(authRepositoryProvider);

    final result = await repository
        .login(email: email, password: password)
        .run();

    result.fold(
      (failure) {
        final message = switch (failure) {
          ServerFailure(message: final msg) => msg,
          _ => failure.message,
        };
        state = LoginState.error(message);
      },
      (user) {
        ref.read(sessionProvider.notifier).setAuthenticated(user);

        state = LoginState.success(user);
      },
    );
  }
}
