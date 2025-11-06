/*
 * ═══════════════════════════════════════════════════════════════════════════
 * BIOMETRIC SERVICE - Fingerprint & Face ID Authentication
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * PURPOSE: Handle biometric authentication (fingerprint, face ID)
 * 
 * CONCEPTS:
 * - local_auth package: Platform-specific biometric APIs
 * - Async operations: Authentication takes time
 * - Error handling: Device might not support biometrics
 * 
 * SUPPORTED BIOMETRICS:
 * - Fingerprint (Android/iOS)
 * - Face ID (iOS)
 * - Face Recognition (Android)
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 */

import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // ═══════════════════════════════════════════════════════════════════════════
  // CHECK IF DEVICE SUPPORTS BIOMETRICS
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // WHAT: Checks if device has biometric hardware
  // WHY: Don't show biometric option if not supported
  // RETURNS: true if device has fingerprint/face ID sensor
  // 
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET AVAILABLE BIOMETRIC TYPES
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // WHAT: Returns list of available biometric types
  // WHY: Know which biometrics are enrolled (fingerprint, face, etc.)
  // RETURNS: List of BiometricType (fingerprint, face, iris, weak, strong)
  // 
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTHENTICATE WITH BIOMETRICS
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // WHAT: Prompts user for biometric authentication
  // WHY: Secure app access without password
  // HOW: Shows system biometric dialog (fingerprint/face ID)
  // 
  // FLOW:
  // 1. Check if biometrics available
  // 2. Show system authentication dialog
  // 3. User provides biometric (fingerprint/face)
  // 4. Return true if authenticated, false if failed/cancelled
  // 
  // PARAMETERS:
  // - localizedReason: Message shown to user explaining why auth needed
  // 
  // RETURNS: true if authenticated successfully, false otherwise
  // 
  Future<bool> authenticate({
    required String localizedReason,
  }) async {
    try {
      // Check if device supports biometrics
      final canAuthenticate = await canCheckBiometrics();
      if (!canAuthenticate) {
        return false;
      }

      // Authenticate with biometrics
      // ═══════════════════════════════════════════════════════════════════════
      // authenticate() parameters:
      // ═══════════════════════════════════════════════════════════════════════
      // - localizedReason: Message shown in auth dialog
      // - options: Authentication options
      //   * biometricOnly: Only use biometrics (no PIN/password fallback)
      //   * stickyAuth: Keep auth dialog until success or explicit cancel
      //   * sensitiveTransaction: Extra security for sensitive operations
      // 
      return await _auth.authenticate(
        localizedReason: localizedReason,
      );
    } on PlatformException catch (e) {
      // Handle errors
      // Common errors:
      // - NotAvailable: No biometric hardware
      // - NotEnrolled: No biometrics enrolled
      // - LockedOut: Too many failed attempts
      // - PermanentlyLockedOut: Device locked
      // - uiUnavailable: Activity not FragmentActivity (Android)
      print('Biometric authentication error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Unexpected biometric error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STOP AUTHENTICATION
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // WHAT: Cancels ongoing authentication
  // WHY: User might want to cancel or app is closing
  // WHEN: App goes to background, user cancels
  // 
  Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } on PlatformException {
      // Ignore errors when stopping
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CHECK IF BIOMETRICS ARE ENROLLED
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // WHAT: Checks if user has enrolled any biometrics
  // WHY: Don't prompt for biometrics if none enrolled
  // RETURNS: true if at least one biometric is enrolled
  // 
  Future<bool> isDeviceSupported() async {
    try {
      final canCheck = await canCheckBiometrics();
      if (!canCheck) return false;

      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET BIOMETRIC TYPE NAME
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // WHAT: Returns user-friendly name for biometric type
  // WHY: Show appropriate message to user
  // EXAMPLE: "Use fingerprint to unlock" vs "Use face ID to unlock"
  // 
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.weak:
        return 'Weak Biometric';
      case BiometricType.strong:
        return 'Strong Biometric';
    }
  }
}
