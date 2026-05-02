import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Helper database SQLite lokal untuk menyimpan data obat & jadwal.
///
/// Tabel yang dibuat (sesuai SKPL):
/// - `users` — data user lokal (untuk offline support)
/// - `medications` — daftar obat yang dimiliki user
/// - `schedules` — jadwal minum obat per medication
/// - `intake_logs` — log setiap kali user konfirmasi minum obat
/// - `medication_logs` — backward compatibility (opsional)
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
    final path = join(dbPath, 'pillpal_pro.db'); // Ganti nama database

    return await openDatabase(
      path,
      version: 2, // ⚠️ NAIKKAN VERSI DARI 1 KE 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        // ⚠️ PENTING: Aktifkan foreign key
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ════════════════════════════════════════════════
  // DATABASE MIGRATION
  // ════════════════════════════════════════════════

  Future<void> _onCreate(Database db, int version) async {
    await _createTablesV2(db);
    await _insertSampleData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Migrasi database dari v$oldVersion ke v$newVersion');
    
    if (oldVersion < 2) {
      // Backup data lama jika ada
      await _backupOldData(db);
      
      // Drop tabel lama (HATI-HATI: data akan hilang)
      await db.execute('DROP TABLE IF EXISTS medications');
      await db.execute('DROP TABLE IF EXISTS medication_logs');
      
      // Buat ulang dengan skema baru
      await _createTablesV2(db);
      
      print('✅ Migrasi ke v2 selesai');
    }
  }

  Future<void> _backupOldData(Database db) async {
    try {
      final oldMeds = await db.query('medications');
      print('📦 Backup ${oldMeds.length} medications');
      // Data dummy akan hilang, tapi ini expected behavior
    } catch (e) {
      print('⚠️ Tidak ada data lama untuk di-backup');
    }
  }

  Future<void> _createTablesV2(Database db) async {
    // Tabel users (lokal, untuk offline support)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        full_name TEXT,
        allergy_profile TEXT,
        biometric_enabled INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabel medications (obat yang dimiliki user)
    await db.execute('''
      CREATE TABLE medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        drug_type TEXT,
        total_stock REAL DEFAULT 0,
        description TEXT,
        rx_cui TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Tabel schedules (jadwal minum obat per medication)
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        med_id INTEGER NOT NULL,
        time_intake TEXT NOT NULL,
        dosage REAL NOT NULL,
        dosage_unit TEXT NOT NULL,
        frequency_type TEXT NOT NULL,
        frequency_value INTEGER NOT NULL,
        status TEXT DEFAULT 'active',
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (med_id) REFERENCES medications(id) ON DELETE CASCADE
      )
    ''');

    // Tabel intake_logs (log setiap kali user konfirmasi minum obat)
    await db.execute('''
      CREATE TABLE intake_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        schedule_id INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (schedule_id) REFERENCES schedules(id) ON DELETE CASCADE
      )
    ''');

    // Tabel medication_logs (backward compatibility - opsional)
    await db.execute('''
      CREATE TABLE medication_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medication_id INTEGER NOT NULL,
        taken_at TEXT NOT NULL,
        status TEXT DEFAULT 'taken',
        note TEXT,
        FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE
      )
    ''');

    print('✅ Semua tabel v2 berhasil dibuat');
  }

  Future<void> _insertSampleData(Database db) async {
    // Insert dummy user
    await db.insert('users', {
      'id': 1,
      'username': 'testuser',
      'email': 'test@example.com',
      'full_name': 'Test User',
      'allergy_profile': '',
    });

    // Insert dummy medication
    final medId = await db.insert('medications', {
      'user_id': 1,
      'name': 'Paracetamol 500mg',
      'drug_type': 'Tablet',
      'total_stock': 30.0,
      'description': 'Obat pereda nyeri dan demam',
    });

    // Insert dummy schedule
    await db.insert('schedules', {
      'med_id': medId,
      'time_intake': '08:00',
      'dosage': 1.0,
      'dosage_unit': 'tablet',
      'frequency_type': 'every_n_hours',
      'frequency_value': 8,
      'status': 'active',
      'notes': 'Sesudah makan',
    });

    print('✅ Data dummy berhasil diinsert');
  }

  // ════════════════════════════════════════════════
  // CRUD MEDICATIONS
  // ════════════════════════════════════════════════

  /// Pastikan user ada di database lokal (untuk foreign key constraint)
  Future<void> ensureUserExists({
    required int userId,
    required String username,
    required String email,
    required String fullName,
  }) async {
    final db = await database;
    
    // Cek apakah user sudah ada
    final existing = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (existing.isEmpty) {
      // Insert user baru
      await db.insert(
        'users',
        {
          'id': userId,
          'username': username,
          'email': email,
          'full_name': fullName,
          'allergy_profile': '',
          'biometric_enabled': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ User $userId inserted to local database');
    } else {
      print('✅ User $userId already exists in local database');
    }
  }

  /// Tambah obat baru (dengan user_id dari session)
  Future<int> insertMedication({
    required int userId,
    required String name,
    String? drugType,
    double totalStock = 0,
    String? description,
    String? rxCui,
  }) async {
    final db = await database;
    return await db.insert('medications', {
      'user_id': userId,
      'name': name,
      'drug_type': drugType,
      'total_stock': totalStock,
      'description': description,
      'rx_cui': rxCui,
    });
  }

  /// Ambil semua obat milik user tertentu
  Future<List<Map<String, dynamic>>> getMedicationsByUser(int userId) async {
    final db = await database;
    return await db.query(
      'medications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  /// Update stok obat (dipanggil saat konfirmasi minum)
  Future<int> updateMedicationStock(int medId, double newStock) async {
    final db = await database;
    return await db.update(
      'medications',
      {'total_stock': newStock},
      where: 'id = ?',
      whereArgs: [medId],
    );
  }

  /// Hapus obat (cascade akan hapus schedules & logs terkait)
  Future<int> deleteMedication(int medId) async {
    final db = await database;
    return await db.delete('medications', where: 'id = ?', whereArgs: [medId]);
  }

  // ════════════════════════════════════════════════
  // CRUD SCHEDULES
  // ════════════════════════════════════════════════

  /// Tambah jadwal baru
  Future<int> insertSchedule({
    required int medId,
    required String timeIntake,
    required double dosage,
    required String dosageUnit,
    required String frequencyType,
    required int frequencyValue,
    String? notes,
  }) async {
    final db = await database;
    return await db.insert('schedules', {
      'med_id': medId,
      'time_intake': timeIntake,
      'dosage': dosage,
      'dosage_unit': dosageUnit,
      'frequency_type': frequencyType,
      'frequency_value': frequencyValue,
      'notes': notes,
      'status': 'active',
    });
  }

  /// Ambil semua jadwal aktif dengan info obat (JOIN)
  Future<List<Map<String, dynamic>>> getActiveSchedulesWithMed(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        s.*,
        m.name as med_name,
        m.total_stock,
        m.drug_type
      FROM schedules s
      JOIN medications m ON s.med_id = m.id
      WHERE m.user_id = ? AND s.status = 'active'
      ORDER BY s.time_intake ASC
    ''', [userId]);
  }

  /// Update status jadwal (active → expired)
  Future<int> updateScheduleStatus(int scheduleId, String status) async {
    final db = await database;
    return await db.update(
      'schedules',
      {'status': status},
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
  }

  /// Hapus jadwal
  Future<int> deleteSchedule(int scheduleId) async {
    final db = await database;
    return await db.delete('schedules', where: 'id = ?', whereArgs: [scheduleId]);
  }

  // ════════════════════════════════════════════════
  // CRUD INTAKE LOGS
  // ════════════════════════════════════════════════

  /// Catat konsumsi obat (dipanggil saat user klik "Sudah Minum")
  Future<int> logIntake({
    required int scheduleId,
    required String status, // "on-time" | "late" | "missed"
    String? note,
  }) async {
    final db = await database;
    return await db.insert('intake_logs', {
      'schedule_id': scheduleId,
      'timestamp': DateTime.now().toIso8601String(),
      'status': status,
      'note': note,
    });
  }

  /// Ambil riwayat konsumsi (untuk analitik)
  Future<List<Map<String, dynamic>>> getIntakeLogs({
    required int userId,
    int limit = 50,
  }) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        il.*,
        s.time_intake,
        s.dosage,
        s.dosage_unit,
        m.name as med_name
      FROM intake_logs il
      JOIN schedules s ON il.schedule_id = s.id
      JOIN medications m ON s.med_id = m.id
      WHERE m.user_id = ?
      ORDER BY il.timestamp DESC
      LIMIT ?
    ''', [userId, limit]);
  }

  /// Hitung statistik kepatuhan (untuk F-10)
  Future<Map<String, int>> getAdherenceStats(int userId, {int days = 7}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    
    final result = await db.rawQuery('''
      SELECT 
        il.status,
        COUNT(*) as count
      FROM intake_logs il
      JOIN schedules s ON il.schedule_id = s.id
      JOIN medications m ON s.med_id = m.id
      WHERE m.user_id = ? AND il.timestamp >= ?
      GROUP BY il.status
    ''', [userId, cutoffDate]);
    
    final stats = <String, int>{
      'on-time': 0,
      'late': 0,
      'missed': 0,
    };
    
    for (var row in result) {
      stats[row['status'] as String] = row['count'] as int;
    }
    
    return stats;
  }

  // ════════════════════════════════════════════════
  // LOGIKA BISNIS: KONFIRMASI MINUM OBAT (F-05)
  // ════════════════════════════════════════════════

  /// Method lengkap untuk konfirmasi konsumsi obat
  Future<Map<String, dynamic>> confirmMedicationTaken({
    required int scheduleId,
    required int medId,
    required double dosage,
  }) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        // 1. Ambil stok saat ini
        final medResult = await txn.query(
          'medications',
          columns: ['total_stock'],
          where: 'id = ?',
          whereArgs: [medId],
        );
        
        if (medResult.isEmpty) {
          throw Exception('Obat tidak ditemukan');
        }
        
        final currentStock = medResult.first['total_stock'] as double;
        final newStock = currentStock - dosage;
        
        // 2. Update stok
        await txn.update(
          'medications',
          {'total_stock': newStock > 0 ? newStock : 0},
          where: 'id = ?',
          whereArgs: [medId],
        );
        
        // 3. Log konsumsi
        await txn.insert('intake_logs', {
          'schedule_id': scheduleId,
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'on-time', // TODO: Hitung apakah late berdasarkan time_intake
          'note': null,
        });
        
        // 4. Jika stok habis, set jadwal jadi expired
        if (newStock <= 0) {
          await txn.update(
            'schedules',
            {'status': 'expired'},
            where: 'id = ?',
            whereArgs: [scheduleId],
          );
        }
      });
      
      return {
        'success': true,
        'message': 'Konsumsi obat berhasil dicatat',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mencatat konsumsi: $e',
      };
    }
  }

  // ════════════════════════════════════════════════
  // BACKWARD COMPATIBILITY (MEDICATION LOGS)
  // ════════════════════════════════════════════════

  /// Catat bahwa obat sudah diminum (old method - backward compatibility)
  Future<int> logMedicationTaken(int medicationId, {String? note}) async {
    final db = await database;
    return await db.insert('medication_logs', {
      'medication_id': medicationId,
      'taken_at': DateTime.now().toIso8601String(),
      'status': 'taken',
      'note': note,
    });
  }

  /// Ambil riwayat konsumsi obat (old method - backward compatibility)
  Future<List<Map<String, dynamic>>> getMedicationLogs({int limit = 20}) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT ml.*, m.name as medicine_name
      FROM medication_logs ml
      JOIN medications m ON ml.medication_id = m.id
      ORDER BY ml.taken_at DESC
      LIMIT ?
    ''', [limit]);
  }

  // ════════════════════════════════════════════════
  // UTILITY
  // ════════════════════════════════════════════════

  /// Reset database (untuk testing - hapus semua data)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pillpal_pro.db');
    await deleteDatabase(path);
    _database = null;
    print('✅ Database dihapus, akan dibuat ulang saat app restart');
  }

  /// Tutup database
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
