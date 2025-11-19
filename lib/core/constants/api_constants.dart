import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.get(
    'API_BASE_URL',
    fallback: 'http://10.0.2.2:8000/api/v1',
  );

  static Duration get connectTimeout {
    final ms = int.tryParse(dotenv.env['CONNECT_TIMEOUT'] ?? '') ?? 15000;
    return Duration(milliseconds: ms);
  }

  static Duration get receiveTimeout {
    final ms = int.tryParse(dotenv.env['RECEIVE_TIMEOUT'] ?? '') ?? 15000;
    return Duration(milliseconds: ms);
  }

  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
}
