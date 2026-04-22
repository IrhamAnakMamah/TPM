import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medication_model.dart';

/// Helper database SQLite lokal untuk menyimpan data obat & jadwal.
///
/// Tabel yang dibuat:
/// - `medications` — daftar obat yang disimpan user
/// - `medication_logs` — riwayat konsumsi obat
class DatabaseHelper {
  // Singleton pattern
  DatabaseHelper._internal();
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medremind_pro.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel obat
    await db.execute('''
      CREATE TABLE medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        time TEXT NOT NULL,
        notes TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabel log konsumsi
    await db.execute('''
      CREATE TABLE medication_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medication_id INTEGER NOT NULL,
        taken_at TEXT NOT NULL,
        status TEXT DEFAULT 'taken',
        note TEXT,
        FOREIGN KEY (medication_id) REFERENCES medications(id)
      )
    ''');

    // Insert contoh data awal
    await db.insert('medications', {
      'name': 'Paracetamol 500mg',
      'dosage': '1 Pil',
      'frequency': '3x Sehari',
      'time': '08:00',
      'notes': 'Sesudah Makan',
    });
    await db.insert('medications', {
      'name': 'Amoxicillin',
      'dosage': '1 Pil',
      'frequency': '2x Sehari',
      'time': '13:00',
      'notes': 'Sebelum Makan',
    });
  }

  // ════════════════════════════════════════════════
  // CRUD MEDICATIONS
  // ════════════════════════════════════════════════

  /// Ambil semua obat aktif.
  Future<List<MedicationModel>> getAllMedications() async {
    final db = await database;
    final result = await db.query(
      'medications',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'time ASC',
    );
    return result.map((m) => MedicationModel.fromMap(m)).toList();
  }

  /// Tambah obat baru.
  Future<int> insertMedication(MedicationModel med) async {
    final db = await database;
    return await db.insert('medications', med.toMap());
  }

  /// Update obat.
  Future<int> updateMedication(MedicationModel med) async {
    final db = await database;
    return await db.update(
      'medications',
      med.toMap(),
      where: 'id = ?',
      whereArgs: [med.id],
    );
  }

  /// Hapus obat (soft delete).
  Future<int> deleteMedication(int id) async {
    final db = await database;
    return await db.update(
      'medications',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ════════════════════════════════════════════════
  // MEDICATION LOGS
  // ════════════════════════════════════════════════

  /// Catat bahwa obat sudah diminum.
  Future<int> logMedicationTaken(int medicationId, {String? note}) async {
    final db = await database;
    return await db.insert('medication_logs', {
      'medication_id': medicationId,
      'taken_at': DateTime.now().toIso8601String(),
      'status': 'taken',
      'note': note,
    });
  }

  /// Ambil riwayat konsumsi obat.
  Future<List<Map<String, dynamic>>> getMedicationLogs({int limit = 20}) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT ml.*, m.name as medicine_name, m.dosage, m.frequency
      FROM medication_logs ml
      JOIN medications m ON ml.medication_id = m.id
      ORDER BY ml.taken_at DESC
      LIMIT ?
    ''', [limit]);
  }

  /// Tutup database.
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
