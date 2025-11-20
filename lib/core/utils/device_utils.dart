import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DeviceUtils {
  static Future<bool> isEmulator() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return !androidInfo.isPhysicalDevice ||
          androidInfo.model.contains('sdk') ||
          androidInfo.product.contains('sdk') ||
          androidInfo.hardware.contains('goldfish') ||
          androidInfo.hardware.contains('ranchu');
    }

    if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      return !iosInfo.isPhysicalDevice;
    }

    return false;
  }
}
