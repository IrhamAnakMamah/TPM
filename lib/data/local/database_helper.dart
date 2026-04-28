import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/schedule_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pillpal_ai.db');
    return await openDatabase(
      path,
      version: 2, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        total_stock REAL NOT NULL
      )
    ''');
    await _createV2Tables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createV2Tables(db);
    }
  }

  Future<void> _createV2Tables(Database db) async {
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

  Future<List<Map<String, dynamic>>> getSchedulesWithMed(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT s.*, m.name as med_name, m.total_stock 
      FROM schedules s
      JOIN medications m ON s.med_id = m.id
      WHERE s.status = 'active'
    ''');
  }

  Future<int> insertSchedule(ScheduleModel schedule) async {
    final db = await database;
    return await db.insert('schedules', schedule.toMap());
  }

  Future<int> updateScheduleStatus(int scheduleId, String status) async {
    final db = await database;
    return await db.update('schedules', {'status': status}, where: 'id = ?', whereArgs: [scheduleId]);
  }

  Future<int> logIntake(int scheduleId, String status) async {
    final db = await database;
    return await db.insert('intake_logs', {
      'schedule_id': scheduleId,
      'timestamp': DateTime.now().toIso8601String(),
      'status': status,
    });
  }

  Future<List<Map<String, dynamic>>> getIntakeLogs({int limit = 50}) async {
    final db = await database;
    return await db.query('intake_logs', orderBy: 'timestamp DESC', limit: limit);
  }
}