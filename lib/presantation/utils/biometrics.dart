import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logging/logging.dart';
import 'package:near_pay_app/service_locator.dart';


class BiometricUtil {
  ///
  /// hasBiometrics()
  ///
  /// @returns [true] if device has fingerprint/faceID available and registered, [false] otherwise
  Future<bool> hasBiometrics() async {
    LocalAuthentication localAuth = LocalAuthentication();
    bool canCheck = await localAuth.canCheckBiometrics;
    if (canCheck) {
      List<BiometricType> availableBiometrics =
          await localAuth.getAvailableBiometrics();
      for (var type in availableBiometrics) {
        sl.get<Logger>().info(type.toString());
        sl.get<Logger>().info(
            type == BiometricType.face ? 'face' : type == BiometricType.iris ? 'iris' : type == BiometricType.fingerprint ? 'fingerprint' : 'unknown');
      }
      if (availableBiometrics.contains(BiometricType.face)) {
        return true;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return true;
      } else if (availableBiometrics.contains(BiometricType.strong)) {
        return true;
      }
    }
    return false;
  }

  ///
  /// authenticateWithBiometrics()
  ///
  /// @param [message] Message shown to user in FaceID/TouchID popup
  /// @returns [true] if successfully authenticated, [false] otherwise
  Future<bool> authenticateWithBiometrics(
      BuildContext context, String message) async {
    bool hasBiometricsEnrolled = await hasBiometrics();
    if (hasBiometricsEnrolled) {
      LocalAuthentication localAuth = LocalAuthentication();
      return await localAuth.authenticate(
          localizedReason: message,
          options: const AuthenticationOptions(useErrorDialogs: false));
    }
    return false;
  }
}
