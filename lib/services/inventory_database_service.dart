import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/inventory_item.dart';

class InventoryDatabaseService {
  InventoryDatabaseService._();

  static final InventoryDatabaseService instance = InventoryDatabaseService._();

  static const _databaseName = 'nextinventory.db';
  static const _databaseVersion = 1;
  static const _tableName = 'inventory_items';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, _databaseName);

    return openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            code TEXT NOT NULL UNIQUE,
            location TEXT NOT NULL,
            status TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<InventoryItem>> getItems() async {
    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'created_at DESC');

    return rows.map(InventoryItem.fromMap).toList();
  }

  Future<void> insertItem(InventoryItem item) async {
    final db = await database;

    await db.insert(_tableName, {
      ...item.toMap(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<void> updateItem(InventoryItem item) async {
    final db = await database;

    await db.update(
      _tableName,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> deleteItem(String id) async {
    final db = await database;

    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
