import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/device_utils.dart';

class ApiConfig {
  static late final String _baseUrl;
  static String get baseUrl => _baseUrl;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static bool _enableHttpLogs = false;
  static bool get enableHttpLogs => _enableHttpLogs;

  static bool _enableDetailedLogs = false;
  static bool get enableDetailedLogs => _enableDetailedLogs;

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    _enableHttpLogs =
        dotenv.get(
          'ENABLE_HTTP_LOGS',
          fallback: kDebugMode ? 'true' : 'false',
        ) ==
        'true';

    _enableDetailedLogs =
        dotenv.get('ENABLE_HTTP_DETAILED_LOGS', fallback: 'false') == 'true';

    if (kReleaseMode) {
      _baseUrl = dotenv.get('API_BASE_URL');
    } else {
      if (kIsWeb) {
        _baseUrl = dotenv.get(
          'BASE_DEV_API_URL_WEB',
          fallback: 'http://localhost:8000/api/v1',
        );
      } else {
        final isEmulator = await DeviceUtils.isEmulator();
        final hostEmulator = 'http://10.0.2.2:8000/api/v1';
        final hostDevice = dotenv.get(
          'API_BASE_URL',
          fallback: 'http://192.168.1.X:8000/api/v1',
        );

        _baseUrl = isEmulator ? hostEmulator : hostDevice;
      }
    }
  }
}
