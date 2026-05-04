import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton pattern
  DatabaseHelper._internal();
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pillpal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        full_name TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        allergy_profile TEXT,
        biometric_enabled INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        name TEXT NOT NULL,
        drug_type TEXT,
        total_stock REAL NOT NULL,
        description TEXT,
        rx_cui TEXT
      )
    ''');

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
        FOREIGN KEY (med_id) REFERENCES medications(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE intake_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        schedule_id INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (schedule_id) REFERENCES schedules(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute("ALTER TABLE users ADD COLUMN biometric_enabled INTEGER DEFAULT 0");
        await db.execute("ALTER TABLE schedules ADD COLUMN notes TEXT");
      } catch (_) {}
    }
  }

  // ==========================================
  // FUNGSI TASK 10 (BIOMETRIK)
  // ==========================================
  Future<bool> isBiometricEnabled(int userId) async {
    final db = await database;
    final result = await db.query('users', columns: ['biometric_enabled'], where: 'id = ?', whereArgs: [userId]);
    if (result.isEmpty) return false;
    return result.first['biometric_enabled'] == 1;
  }

  Future<int> setBiometricEnabled(int userId, bool enabled) async {
    final db = await database;
    return await db.update('users', {'biometric_enabled': enabled ? 1 : 0}, where: 'id = ?', whereArgs: [userId]);
  }

  // ==========================================
  // FUNGSI USERS
  // ==========================================
  Future<void> ensureUserExists({required int userId, required String username, required String email, required String fullName}) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (result.isEmpty) {
      await db.insert('users', {
        'id': userId,
        'username': username,
        'email': email,
        'full_name': fullName,
        'password_hash': 'dummy',
      });
    }
  }

  // ==========================================
  // FUNGSI MEDICATIONS (OBAT) - DIUBAH PAKE NAMED PARAMETERS
  // ==========================================
  Future<int> insertMedication({
    required int userId,
    required String name,
    String? drugType,
    required double totalStock,
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

  Future<Map<String, dynamic>?> getMedicationById(int id) async {
    final db = await database;
    final result = await db.query('medications', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  // DIUBAH PAKE NAMED PARAMETERS SESUAI UI
  Future<Map<String, dynamic>?> findMedicationByNameAndDose({required int userId, required String name}) async {
    final db = await database;
    final result = await db.query(
      'medications',
      where: 'user_id = ? AND name = ?',
      whereArgs: [userId, name],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> addMedicationStock(int medId, dynamic newStock) async {
    final db = await database;
    await db.update('medications', {'total_stock': newStock}, where: 'id = ?', whereArgs: [medId]);
  }

  // ==========================================
  // FUNGSI SCHEDULES (JADWAL) - DIUBAH PAKE NAMED PARAMETERS
  // ==========================================
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
      'status': 'active'
    });
  }

  Future<void> updateSchedule({
    required int scheduleId,
    required String timeIntake,
    required double dosage,
    required String dosageUnit,
    required String frequencyType,
    required int frequencyValue,
  }) async {
    final db = await database;
    await db.update('schedules', {
      'time_intake': timeIntake,
      'dosage': dosage,
      'dosage_unit': dosageUnit,
      'frequency_type': frequencyType,
      'frequency_value': frequencyValue,
    }, where: 'id = ?', whereArgs: [scheduleId]);
  }

  Future<void> deleteSchedule(int id) async {
    final db = await database;
    await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getScheduleById(int id) async {
    final db = await database;
    final result = await db.query('schedules', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getActiveSchedulesWithMed(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT s.*, m.name as medication_name, m.total_stock 
      FROM schedules s
      JOIN medications m ON s.med_id = m.id
      WHERE s.status = 'active' AND m.user_id = ?
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getSchedulesByMedicationId(int medId) async {
    final db = await database;
    return await db.query('schedules', where: 'med_id = ?', whereArgs: [medId]);
  }

  Future<int> updateScheduleStatus(int scheduleId, String status) async {
    final db = await database;
    return await db.update('schedules', {'status': status}, where: 'id = ?', whereArgs: [scheduleId]);
  }

  // ==========================================
  // FUNGSI STATISTIK & INTAKE LOGS
  // ==========================================
  Future<List<Map<String, dynamic>>> getTodayIntakeLogs(int scheduleId) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return await db.rawQuery('''
      SELECT * FROM intake_logs 
      WHERE schedule_id = ? AND timestamp LIKE '$today%'
    ''', [scheduleId]);
  }

  Future<Map<String, int>> getAdherenceStats(int userId, {int days = 1}) async {
    final db = await database;
    // Ini versi disederhanakan, idealnya di-join ke tabel medications buat filter userId
    final result = await db.rawQuery('SELECT status, COUNT(*) as count FROM intake_logs GROUP BY status');
    Map<String, int> stats = {'on-time': 0, 'late': 0, 'missed': 0};
    for (var row in result) {
      stats[row['status'] as String] = row['count'] as int;
    }
    return stats;
  }

  Future<Map<String, dynamic>> confirmMedicationTaken({required int scheduleId, required int medId, required double dosage}) async {
    try {
      final db = await database;
      
      await db.insert('intake_logs', {
        'schedule_id': scheduleId,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'on-time'
      });

      final med = await getMedicationById(medId);
      if (med != null) {
        double currentStock = (med['total_stock'] as num).toDouble();
        double newStock = currentStock - dosage;
        await db.update('medications', {'total_stock': newStock}, where: 'id = ?', whereArgs: [medId]);
        
        if (newStock <= 0) {
          await db.update('schedules', {'status': 'expired'}, where: 'id = ?', whereArgs: [scheduleId]);
        }
      }
      return {'success': true, 'message': 'Berhasil diminum!'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal: ${e.toString()}'};
    }
  }
}