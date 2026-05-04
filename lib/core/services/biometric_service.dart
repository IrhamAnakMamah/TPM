import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticate({
    String localizedReason = 'Verifikasi identitas Anda untuk masuk',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final canCheck = await canCheckBiometrics();
      final isSupported = await isDeviceSupported();

      if (!canCheck || !isSupported) return false;

      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false,
        ),
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Verifikasi Biometrik',
            cancelButton: 'Batal',
            biometricHint: 'Verifikasi identitas',
            biometricNotRecognized: 'Tidak dikenali',
            biometricSuccess: 'Berhasil',
            deviceCredentialsRequiredTitle: 'Verifikasi diperlukan',
          ),
          IOSAuthMessages(
            cancelButton: 'Batal',
            goToSettingsButton: 'Pengaturan',
            goToSettingsDescription: 'Aktifkan biometrik di pengaturan',
            lockOut: 'Biometrik terkunci. Coba lagi nanti.',
          ),
        ],
      );
    } catch (e) {
      return false;
    }
  }

  Future<String> getBiometricTypeName() async {
    final types = await getAvailableBiometrics();
    if (types.isEmpty) return 'Biometrik';
    
    if (types.contains(BiometricType.face)) return 'Face ID';
    if (types.contains(BiometricType.fingerprint)) return 'Sidik Jari';
    if (types.contains(BiometricType.iris)) return 'Iris';
    return 'Biometrik';
  }
}