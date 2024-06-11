import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Pin.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pins.db');

    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE pins(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, latitude REAL, longitude REAL)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertPin(Pin pin) async {
    final db = await database();
    await db.insert(
      'pins',
      pin.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Pin>> getPins() async {
    final db = await database();
    final List<Map<String, dynamic>> maps = await db.query('pins');
    return List.generate(maps.length, (i) {
      return Pin.fromMap(maps[i]);
    });
  }

  static Future<void> deletePin(int id) async {
    final db = await database();
    await db.delete(
      'pins',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteAllPins() async {
    final db = await database();
    await db.delete('pins');
  }
}
