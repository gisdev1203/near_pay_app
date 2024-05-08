import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:vibration/vibration.dart';

class DeviceUtils {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  static Future<Object?> getDeviceId() async {
    try {
      if (kIsWeb) {
        return await _getWebDeviceId();
      } else {
        return await _getNativeDeviceId();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device ID: $e');
      }
      return null;
    }
  }

  static Future<String?> _getWebDeviceId() async {
    // Implement web-specific device ID retrieval logic
    return null;
  }

  static Future<Object?> _getNativeDeviceId() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      return androidInfo.supportedAbis; // This should work if you have the latest version of device_info_plus
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await _deviceInfoPlugin.iosInfo;
      return iosInfo.identifierForVendor; // Same for iOS
    }
    return null;
  }

  static Future<String?> getOSVersion() async { // Changed method name for clarity
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.version.release; // Correct way to get platform version for Android
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.systemVersion; // Correct way for iOS
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting OS version: $e');
      }
      return null;
    }
  }

  static Future<void> vibrate({Duration duration = const Duration(milliseconds: 500)}) async {
    try {
      if (await Vibration.hasVibrator() ?? false) { // Check if the device has a vibrator
        await Vibration.vibrate(duration: duration.inMilliseconds);
      }      
    } catch (e) {
      if (kDebugMode) {
        print('Error vibrating device: $e');
      }
    }
  }
}