import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_event_notifier.g.dart';

enum AuthEvent {
  none,
  forceLogout,
}

@Riverpod(keepAlive: true)
class AuthEventNotifier extends _$AuthEventNotifier {
  @override
  AuthEvent build() {
    return AuthEvent.none;
  }

  void emit(AuthEvent event) {
    state = event;
    Future.delayed(const Duration(milliseconds: 100), () {
      state = AuthEvent.none;
    });
  }
}
