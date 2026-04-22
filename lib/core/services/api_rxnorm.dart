import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import 'session_manager.dart';

/// Service untuk pencarian obat via RxNorm API melalui backend.
///
/// RxNorm adalah database obat dari NIH (National Library of Medicine).
/// Digunakan untuk mencari informasi obat berdasarkan nama.
class ApiRxnorm {
  final SessionManager _session = SessionManager();

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_session.accessToken}',
      };

  /// Cari obat berdasarkan nama.
  /// Mengembalikan list hasil dari RxNorm.
  Future<List<Map<String, dynamic>>> searchDrug(String name) async {
    try {
      final uri = Uri.parse(ApiConfig.searchDrugUrl).replace(
        queryParameters: {'name': name},
      );
      final response = await http.get(uri, headers: _authHeaders);
      final data = jsonDecode(response.body);

      if (data['status'] == 'ok') {
        final results = data['results'] as List<dynamic>? ?? [];
        return results.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Test koneksi ke RxNorm API.
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.pingRxnormUrl),
        headers: _authHeaders,
      );
      final data = jsonDecode(response.body);
      return data['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }
}
