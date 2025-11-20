import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/app.dart';

import 'core/config/api_config.dart';
import 'core/constants/hive_box_names.dart'; // Importante

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiConfig.initialize();

  await Hive.initFlutter();

  await Hive.openBox(HiveBoxNames.auth);
  await Hive.openBox(HiveBoxNames.preferences);

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
