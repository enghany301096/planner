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
        return true; // If device doesn't support, we might fallback or just allow (depending on requirements, here allowing for simple dev flow)
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access Masrofy',
        biometricOnly: true, // Force biometrics
        persistAcrossBackgrounding: true,
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      log("Biometric Error: $e");
      return false;
    }
  }
}
