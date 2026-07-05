import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class AppDeviceInfo {
  final String deviceId;
  final String model;
  final String osVersion;
  final String platform;

  AppDeviceInfo({
    required this.deviceId,
    required this.model,
    required this.osVersion,
    required this.platform,
  });

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'model': model,
      'osVersion': osVersion,
      'platform': platform,
    };
  }
}

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  Future<AppDeviceInfo> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfoPlugin.webBrowserInfo;
        return AppDeviceInfo(
          deviceId: webInfo.userAgent ?? 'web-unknown',
          model: webInfo.browserName.name,
          osVersion: webInfo.platform ?? 'unknown',
          platform: 'web',
        );
      }

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return AppDeviceInfo(
          deviceId: androidInfo.id, // Consistent Android build/device ID
          model: '${androidInfo.brand} ${androidInfo.model}',
          osVersion: 'Android ${androidInfo.version.release}',
          platform: 'android',
        );
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return AppDeviceInfo(
          deviceId: iosInfo.identifierForVendor ?? 'ios-unknown-id',
          model: iosInfo.name,
          osVersion: '${iosInfo.systemName} ${iosInfo.systemVersion}',
          platform: 'ios',
        );
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfoPlugin.macOsInfo;
        return AppDeviceInfo(
          deviceId: macInfo.systemGUID ?? 'macos-unknown',
          model: macInfo.model,
          osVersion: macInfo.osRelease,
          platform: 'macos',
        );
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfoPlugin.windowsInfo;
        return AppDeviceInfo(
          deviceId: windowsInfo.deviceId,
          model: windowsInfo.computerName,
          osVersion: windowsInfo.productName,
          platform: 'windows',
        );
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }

    return AppDeviceInfo(
      deviceId: 'fallback-unknown-id',
      model: 'Fallback Model',
      osVersion: 'Unknown OS',
      platform: 'unknown',
    );
  }
}
