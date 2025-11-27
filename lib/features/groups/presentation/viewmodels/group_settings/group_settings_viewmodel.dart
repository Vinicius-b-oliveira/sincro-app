import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/features/groups/groups_providers.dart';
import 'package:sincro/features/groups/presentation/viewmodels/group_detail/group_detail_viewmodel.dart';
import 'package:sincro/features/groups/presentation/viewmodels/group_settings/group_settings_state.dart';

part 'group_settings_viewmodel.g.dart';

@riverpod
class GroupSettingsViewModel extends _$GroupSettingsViewModel {
  @override
  GroupSettingsState build(String groupId) {
    Future.microtask(() => loadSettings());
    return const GroupSettingsState.initial();
  }

  Future<void> loadSettings() async {
    state = const GroupSettingsState.loading();
    final repository = ref.read(groupsRepositoryProvider);

    final result = await repository.getGroup(groupId).run();

    result.fold(
      (failure) =>
          state = GroupSettingsState.error(_mapFailureMessage(failure)),
      (group) => state = GroupSettingsState.loaded(group),
    );
  }

  Future<void> updateSetting({
    bool? membersCanAddTransactions,
    bool? membersCanInvite,
  }) async {
    final currentState = state;
    if (currentState is! GroupSettingsLoaded) return;

    final repository = ref.read(groupsRepositoryProvider);

    final result = await repository
        .updateGroup(
          id: groupId,
          membersCanAddTransactions: membersCanAddTransactions,
          membersCanInvite: membersCanInvite,
        )
        .run();

    result.fold(
      (failure) {},
      (updatedGroup) {
        state = GroupSettingsState.loaded(updatedGroup);
        ref.invalidate(groupDetailViewModelProvider(groupId));
      },
    );
  }

  Future<void> exportData() async {
    final currentState = state;
    if (currentState is! GroupSettingsLoaded) return;

    final currentGroup = currentState.group;

    state = const GroupSettingsState.loading();

    final preparePathTask = TaskEither<AppFailure, String>.tryCatch(
      () async {
        if (Platform.isAndroid) {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            if (await Permission.manageExternalStorage.isGranted == false) {
              await Permission.manageExternalStorage.request();
            }
            if (await Permission.storage.isDenied) {
              throw Exception('Permissão de armazenamento negada.');
            }
          }
        }

        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
          directory ??= await getApplicationDocumentsDirectory();
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final fileName = 'export_grupo_${groupId}_$timestamp.csv';

        return '${directory.path}/$fileName';
      },
      (error, stack) =>
          GeneralFailure(message: 'Erro ao preparar arquivo: $error'),
    );

    final exportTask = preparePathTask.flatMap((savePath) {
      final repository = ref.read(groupsRepositoryProvider);
      return repository
          .exportGroup(groupId: groupId, savePath: savePath)
          .map((_) => savePath);
    });

    final result = await exportTask.run();

    result.fold(
      (failure) {
        state = GroupSettingsState.loaded(currentGroup);
        state = GroupSettingsState.error(_mapFailureMessage(failure));
        Future.delayed(const Duration(milliseconds: 100), () {
          state = GroupSettingsState.loaded(currentGroup);
        });
      },
      (savePath) {
        state = GroupSettingsState.loaded(currentGroup);
        state = GroupSettingsState.success('Arquivo salvo em: $savePath');
        Future.delayed(const Duration(milliseconds: 100), () {
          state = GroupSettingsState.loaded(currentGroup);
        });
      },
    );
  }

  Future<void> clearHistory() async {
    final currentState = state;
    if (currentState is! GroupSettingsLoaded) return;

    final currentGroup = currentState.group;
    state = const GroupSettingsState.loading();

    final repository = ref.read(groupsRepositoryProvider);
    final result = await repository.clearHistory(groupId).run();

    result.fold(
      (failure) {
        state = GroupSettingsState.loaded(currentGroup);
        state = GroupSettingsState.error(_mapFailureMessage(failure));
        Future.delayed(const Duration(milliseconds: 100), () {
          state = GroupSettingsState.loaded(currentGroup);
        });
      },
      (_) {
        ref.invalidate(groupDetailViewModelProvider(groupId));

        state = GroupSettingsState.loaded(currentGroup);
        state = const GroupSettingsState.success(
          'Histórico limpo com sucesso.',
        );
        Future.delayed(const Duration(milliseconds: 100), () {
          state = GroupSettingsState.loaded(currentGroup);
        });
      },
    );
  }

  String _mapFailureMessage(AppFailure failure) {
    return switch (failure) {
      ValidationFailure(message: final msg) => msg,
      ServerFailure(message: final msg) => msg,
      GeneralFailure(message: final msg) => msg,
      _ => failure.message,
    };
  }
}
