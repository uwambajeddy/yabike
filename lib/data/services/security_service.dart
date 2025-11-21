import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Service for handling app security (PIN and biometric authentication)
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _pinKey = 'security_pin';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _securityEnabledKey = 'security_enabled';

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Check if device is enrolled with biometrics
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access YaBike',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print('Biometric authentication error: ${e.message}');
      return false;
    }
  }

  /// Hash PIN for secure storage
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Set up security with PIN
  Future<void> setPin(String pin) async {
    final box = Hive.box('settings');
    final hashedPin = _hashPin(pin);
    await box.put(_pinKey, hashedPin);
    await box.put(_securityEnabledKey, true);
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final box = Hive.box('settings');
    final storedHash = box.get(_pinKey);
    if (storedHash == null) return false;
    
    final hashedPin = _hashPin(pin);
    return hashedPin == storedHash;
  }

  /// Check if PIN is set
  bool isPinSet() {
    final box = Hive.box('settings');
    return box.get(_pinKey) != null;
  }

  /// Enable biometric authentication
  Future<void> enableBiometric() async {
    final box = Hive.box('settings');
    await box.put(_biometricEnabledKey, true);
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    final box = Hive.box('settings');
    await box.put(_biometricEnabledKey, false);
  }

  /// Check if biometric is enabled
  bool isBiometricEnabled() {
    final box = Hive.box('settings');
    return box.get(_biometricEnabledKey, defaultValue: false) as bool;
  }

  /// Check if any security is enabled
  bool isSecurityEnabled() {
    final box = Hive.box('settings');
    return box.get(_securityEnabledKey, defaultValue: false) as bool;
  }

  /// Disable all security
  Future<void> disableSecurity() async {
    final box = Hive.box('settings');
    await box.delete(_pinKey);
    await box.put(_biometricEnabledKey, false);
    await box.put(_securityEnabledKey, false);
  }

  /// Change PIN
  Future<void> changePin(String newPin) async {
    await setPin(newPin);
  }

  /// Get biometric type name
  String getBiometricTypeName(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.contains(BiometricType.strong) || types.contains(BiometricType.weak)) {
      return 'Biometric';
    }
    return 'Biometric';
  }
}
