import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sincro/core/storage/storage_providers.dart';
import 'package:sincro/core/theme/repositories/theme_repository.dart';
import 'package:sincro/core/theme/repositories/theme_repository_impl.dart';

part 'theme_providers.g.dart';

@Riverpod(keepAlive: true)
ThemeRepository themeRepository(Ref ref) {
  return ThemeRepositoryImpl(ref.watch(hiveServiceProvider));
}
