import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import 'session_manager.dart';

/// Service langsung untuk Gemini AI via backend FastAPI.
///
/// Digunakan oleh fitur-fitur yang membutuhkan akses Gemini
/// secara langsung (misal: analisis foto obat, AI summary).
class ApiGemini {
  final SessionManager _session = SessionManager();

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_session.accessToken}',
      };

  /// Kirim pertanyaan ke Gemini AI dan terima jawaban.
  Future<String> askQuestion(String question) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.askGeminiUrl),
        headers: _authHeaders,
        body: jsonEncode({'question': question}),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'ok') {
        return data['answer'] ?? 'Tidak ada jawaban.';
      } else {
        return 'Error: ${data['message'] ?? 'Gagal mendapatkan jawaban AI.'}';
      }
    } catch (e) {
      return 'Gagal menghubungi server AI: $e';
    }
  }

  /// Test koneksi ke Gemini AI.
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.pingGeminiUrl),
        headers: _authHeaders,
      );
      final data = jsonDecode(response.body);
      return data['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  /// Analisis gambar obat (mengirim deskripsi teks ke Gemini).
  /// Untuk kamera scan: kirim deskripsi apa yang terlihat di foto.
  Future<String> analyzeMedicine(String description) async {
    final prompt =
        'Saya mengambil foto obat dan melihat: "$description". '
        'Tolong identifikasi nama obat, dosis yang disarankan, '
        'efek samping, dan peringatan penting.';
    return await askQuestion(prompt);
  }
}
