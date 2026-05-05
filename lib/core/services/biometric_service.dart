import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// Service untuk mengelola autentikasi biometrik
/// Menggunakan local_auth untuk fingerprint/face recognition
class BiometricService {
  // Singleton pattern
  BiometricService._internal();
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;

  final LocalAuthentication _localAuth = LocalAuthentication();

  // ══════════════════════════════════════════════════════════════
  // CHECK BIOMETRIC AVAILABILITY
  // ══════════════════════════════════════════════════════════════

  /// Check if device supports biometric authentication
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      print('❌ Error checking biometrics: $e');
      return false;
    }
  }

  /// Check if device has biometric hardware
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      print('❌ Error checking device support: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  /// Returns: [BiometricType.face, BiometricType.fingerprint, etc.]
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('❌ Error getting available biometrics: $e');
      return [];
    }
  }

  /// Check if biometric is available and enrolled
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await canCheckBiometrics();
      final isSupported = await isDeviceSupported();
      final availableBiometrics = await getAvailableBiometrics();
      
      return canCheck && isSupported && availableBiometrics.isNotEmpty;
    } catch (e) {
      print('❌ Error checking biometric availability: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // AUTHENTICATE
  // ══════════════════════════════════════════════════════════════

  /// Authenticate user with biometric
  /// 
  /// Returns:
  /// - true: Authentication successful
  /// - false: Authentication failed or cancelled
  Future<bool> authenticate({
    String localizedReason = 'Verifikasi identitas Anda untuk melanjutkan',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      // Check if biometric is available
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        print('⚠️ Biometric not available on this device');
        return false;
      }

      // Authenticate
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // Allow PIN/Pattern as fallback
        ),
      );

      if (authenticated) {
        print('✅ Biometric authentication successful');
      } else {
        print('❌ Biometric authentication failed');
      }

      return authenticated;
    } on Exception catch (e) {
      print('❌ Error during authentication: $e');
      
      // Handle specific errors
      if (e.toString().contains(auth_error.notAvailable)) {
        print('⚠️ Biometric not available');
      } else if (e.toString().contains(auth_error.notEnrolled)) {
        print('⚠️ No biometric enrolled');
      } else if (e.toString().contains(auth_error.lockedOut)) {
        print('⚠️ Too many attempts, locked out');
      } else if (e.toString().contains(auth_error.permanentlyLockedOut)) {
        print('⚠️ Permanently locked out');
      }
      
      return false;
    }
  }

  /// Authenticate for login
  Future<bool> authenticateForLogin() async {
    return await authenticate(
      localizedReason: 'Login dengan sidik jari atau wajah Anda',
      useErrorDialogs: true,
      stickyAuth: true,
    );
  }

  /// Authenticate for sensitive action
  Future<bool> authenticateForAction(String action) async {
    return await authenticate(
      localizedReason: 'Verifikasi identitas untuk $action',
      useErrorDialogs: true,
      stickyAuth: false,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // UTILITY
  // ══════════════════════════════════════════════════════════════

  /// Get biometric type name for display
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Sidik Jari';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Biometrik Kuat';
      case BiometricType.weak:
        return 'Biometrik Lemah';
      default:
        return 'Biometrik';
    }
  }

  /// Get available biometric names as string
  Future<String> getAvailableBiometricNames() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.isEmpty) {
      return 'Tidak ada';
    }
    
    return biometrics
        .map((type) => getBiometricTypeName(type))
        .join(', ');
  }

  /// Stop authentication (cancel)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
      print('🛑 Authentication stopped');
    } catch (e) {
      print('❌ Error stopping authentication: $e');
    }
  }
}
