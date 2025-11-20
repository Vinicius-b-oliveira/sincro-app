import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/session/session_notifier.dart';
import 'package:sincro/features/auth/auth_providers.dart';
import 'package:sincro/features/auth/presentation/viewmodels/signup/signup_state.dart';

part 'signup_viewmodel.g.dart';

@riverpod
class SignUpViewModel extends _$SignUpViewModel {
  @override
  SignUpState build() {
    return const SignUpState.initial();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const SignUpState.loading();

    final repository = ref.read(authRepositoryProvider);

    final result = await repository
        .register(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
        )
        .run();

    result.fold(
      (failure) {
        final message = switch (failure) {
          ValidationFailure(message: final msg) => msg,
          ServerFailure(message: final msg) => msg,
          _ => failure.message,
        };
        state = SignUpState.error(message);
      },
      (user) {
        ref.read(sessionProvider.notifier).setAuthenticated(user);
        state = SignUpState.success(user);
      },
    );
  }
}
