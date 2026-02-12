import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  static BiometricAuthService get instance => _instance;

  final LocalAuthentication _localAuth;

  String? lastErrorCode;

  BiometricAuthService._internal() : _localAuth = LocalAuthentication();

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      lastErrorCode = e.code;
      return false;
    }
  }

  Future<bool> canCheckBiometrics() async {
    try {
      lastErrorCode = null;
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      return canCheck && supported;
    } on PlatformException catch (e) {
      lastErrorCode = e.code;
      return false;
    } catch (_) {
      lastErrorCode = 'unknown';
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      lastErrorCode = null;
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      lastErrorCode = e.code;
      return <BiometricType>[];
    } catch (_) {
      lastErrorCode = 'unknown';
      return <BiometricType>[];
    }
  }

  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (_) {
      // Ignore
    }
  }

  Future<bool> authenticate({required String reason}) async {
    final okToAsk = await canCheckBiometrics();
    if (!okToAsk) return false;

    try {
      lastErrorCode = null;
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );
    } on PlatformException catch (e) {
      lastErrorCode = e.code;
      return false;
    } catch (_) {
      lastErrorCode = 'unknown';
      return false;
    }
  }
}
