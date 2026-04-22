/// Model user yang sesuai dengan respons backend FastAPI.
///
/// Digunakan untuk menyimpan dan menampilkan data profil user
/// yang didapat dari endpoint `/api/auth/me`.
class UserModel {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.createdAt,
  });

  /// Buat UserModel dari JSON response backend.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  /// Konversi ke Map (untuk SQLite lokal jika diperlukan).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Mendapatkan nama tampilan (full_name atau username).
  String get displayName => fullName ?? username;

  /// Mendapatkan inisial untuk avatar.
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }
}
