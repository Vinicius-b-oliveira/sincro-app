import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/models/user_model.dart';
import 'package:sincro/core/session/session_state.dart';
import 'package:sincro/core/storage/storage_providers.dart';
import 'package:sincro/core/utils/logger.dart';

part 'session_notifier.g.dart';

@Riverpod(keepAlive: true)
class SessionNotifier extends _$SessionNotifier {
  @override
  SessionState build() {
    Future.microtask(() => _restoreSession());
    return const SessionState.initial();
  }

  Future<void> _restoreSession() async {
    state = const SessionState.loading();

    final secureStorage = ref.read(secureStorageServiceProvider);
    final hiveService = ref.read(hiveServiceProvider);

    final tokensResult = await secureStorage.getTokens().run();

    tokensResult.fold(
      (failure) {
        log.e('Falha ao ler tokens no boot: ${failure.message}');
        state = const SessionState.unauthenticated();
      },
      (tokens) async {
        if (tokens == null) {
          state = const SessionState.unauthenticated();
          return;
        }

        final userResult = await hiveService.getUser().run();

        userResult.fold(
          (failure) {
            log.e('Falha ao ler usuário no boot: ${failure.message}');
            state = const SessionState.unauthenticated();
          },
          (user) {
            if (user != null) {
              log.i('Sessão restaurada para: ${user.email}');
              state = SessionState.authenticated(user);
            } else {
              state = const SessionState.unauthenticated();
            }
          },
        );
      },
    );
  }

  void setAuthenticated(UserModel user) {
    state = SessionState.authenticated(user);
  }

  void setUnauthenticated() {
    state = const SessionState.unauthenticated();
  }
}
