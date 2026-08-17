import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'local_storage.dart';

class SqliteStorage implements LocalStorage {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE app_config (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE students (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT
          )
        ''');
      },
    );
  }

  @override
  Future<String?> getString(String key) async {
    final db = await database;
    final maps = await db.query(
      'app_config',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) return maps.first['value'] as String?;
    return null;
  }

  @override
  Future<bool> setString(String key, String value) async {
    final db = await database;
    final result = await db.insert(
      'app_config',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result > 0;
  }

  @override
  Future<bool?> getBool(String key) async {
    final val = await getString(key);
    if (val == null) return null;
    return val == 'true';
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    return await setString(key, value.toString());
  }

  @override
  Future<bool> remove(String key) async {
    final db = await database;
    final count = await db.delete(
      'app_config',
      where: 'key = ?',
      whereArgs: [key],
    );
    return count > 0;
  }
}