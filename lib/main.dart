import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/app.dart';
import 'package:sincro/core/storage/hive_service.dart';

import 'core/config/api_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiConfig.initialize();

  await Hive.initFlutter();

  await HiveService.init();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
