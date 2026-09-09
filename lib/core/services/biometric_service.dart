import 'dart:developer';

import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        return false;
      }

      return await auth.authenticate(
        localizedReason: 'Please authenticate to access Smart Planner',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e) {
      log("Biometric Error: $e");
      return false;
    }
  }
}
