import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Helper enkripsi menggunakan SHA-256 (dari package `crypto`).
///
/// Digunakan untuk hashing lokal (misal: menyimpan hash password di SQLite).
/// Catatan: Backend menggunakan PBKDF2-SHA256 yang lebih aman untuk auth.
class EncryptionHelper {
  /// Hash teks menggunakan SHA-256.
  /// Mengembalikan string hex 64 karakter.
  static String hashSHA256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hash password dengan salt untuk keamanan tambahan.
  static String hashWithSalt(String password, String salt) {
    return hashSHA256('$salt:$password');
  }

  /// Generate salt sederhana dari timestamp.
  static String generateSalt() {
    return hashSHA256(DateTime.now().microsecondsSinceEpoch.toString())
        .substring(0, 16);
  }

  /// Verifikasi password terhadap hash.
  static bool verifyPassword(String password, String salt, String hash) {
    return hashWithSalt(password, salt) == hash;
  }

  /// Encode teks ke Base64.
  static String encodeBase64(String input) {
    return base64Encode(utf8.encode(input));
  }

  /// Decode teks dari Base64.
  static String decodeBase64(String encoded) {
    return utf8.decode(base64Decode(encoded));
  }
}
