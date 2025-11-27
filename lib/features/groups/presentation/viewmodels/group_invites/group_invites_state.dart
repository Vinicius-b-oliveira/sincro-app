import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/features/groups/data/models/invitation_model.dart';

part 'group_invites_state.freezed.dart';

@freezed
abstract class GroupInvitesState with _$GroupInvitesState {
  const factory GroupInvitesState({
    @Default(AsyncValue.loading()) AsyncValue<List<InvitationModel>> invites,
    int? processingInviteId,
    String? error,
    String? successMessage,
  }) = _GroupInvitesState;
}
