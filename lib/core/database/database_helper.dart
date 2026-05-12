import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'luna.db');

    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        cycle_length INTEGER NOT NULL,
        period_length INTEGER NOT NULL,
        onboarded INTEGER NOT NULL DEFAULT 0,
        default_flow TEXT,
        default_moods TEXT,
        user_name TEXT,
        user_nickname TEXT,
        user_birthday TEXT,
        diet_type TEXT,
        allergies TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE periods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        flow TEXT,
        mood TEXT,
        symptoms TEXT,
        notes TEXT,
        medical_log TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE settings ADD COLUMN default_flow TEXT');
      await db.execute('ALTER TABLE settings ADD COLUMN default_moods TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE settings ADD COLUMN user_name TEXT');
      await db.execute('ALTER TABLE settings ADD COLUMN user_nickname TEXT');
      await db.execute('ALTER TABLE settings ADD COLUMN user_birthday TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE daily_logs ADD COLUMN medical_log TEXT');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE settings ADD COLUMN diet_type TEXT');
      await db.execute('ALTER TABLE settings ADD COLUMN allergies TEXT');
    }
  }

  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete('settings');
    await db.delete('periods');
    await db.delete('daily_logs');
  }
}
