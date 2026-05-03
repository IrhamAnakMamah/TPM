/// Utilitas konversi waktu antar zona waktu Indonesia + London.
///
/// Zona waktu yang didukung (sesuai syarat tugas):
/// - WIB  (UTC+7) — Waktu Indonesia Barat
/// - WITA (UTC+8) — Waktu Indonesia Tengah
/// - WIT  (UTC+9) — Waktu Indonesia Timur
/// - London (UTC+0/+1) — GMT/BST
class TimeConverter {
  // Offset UTC dalam jam
  static const Map<String, int> _offsets = {
    'WIB': 7,
    'WITA': 8,
    'WIT': 9,
    'London': 0, // GMT (simplified, tidak memperhitungkan DST)
  };

  /// Hitung selisih jam antara dua zona waktu.
  /// Positif = tujuan lebih cepat, negatif = tujuan lebih lambat.
  static int getTimeDifference(String fromZone, String toZone) {
    final fromOffset = _offsets[fromZone] ?? 7;
    final toOffset = _offsets[toZone] ?? 7;
    return toOffset - fromOffset;
  }

  /// Konversi waktu dari satu zona ke zona lain.
  /// Mengembalikan DateTime yang sudah dikonversi.
  static DateTime convertTime(DateTime time, String fromZone, String toZone) {
    final diff = getTimeDifference(fromZone, toZone);
    return time.add(Duration(hours: diff));
  }

  /// Dapatkan waktu sekarang untuk zona tertentu.
  static DateTime getCurrentTimeInZone(String zone) {
    final now = DateTime.now().toUtc();
    final offset = _offsets[zone] ?? 7;
    return now.add(Duration(hours: offset));
  }

  /// Format deskripsi selisih waktu.
  /// Contoh: "WITA lebih cepat 1 jam dari WIB"
  static String describeTimeDifference(String fromZone, String toZone) {
    final diff = getTimeDifference(fromZone, toZone);
    if (diff == 0) return '$fromZone dan $toZone memiliki waktu yang sama';
    if (diff > 0) return '$toZone lebih cepat $diff jam dari $fromZone';
    return '$toZone lebih lambat ${diff.abs()} jam dari $fromZone';
  }

  /// Daftar zona waktu yang tersedia.
  static List<String> get availableTimezones => _offsets.keys.toList();
}
