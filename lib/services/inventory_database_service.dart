import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/inventory_item.dart';

class InventoryDatabaseException implements Exception {
  InventoryDatabaseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class InventoryDatabaseService {
  InventoryDatabaseService._();

  static final InventoryDatabaseService instance = InventoryDatabaseService._();

  static const _databaseName = 'nextinventory.db';
  static const _databaseVersion = 1;
  static const _tableName = 'inventory_items';

  Database? _database;

  Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, _databaseName);
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasePath();

    return openDatabase(
      dbPath,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
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

        await db.execute(
          'CREATE INDEX idx_inventory_items_created_at ON $_tableName (created_at DESC)',
        );
      },
    );
  }

  Future<List<InventoryItem>> getItems() async {
    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'created_at DESC');

    return rows.map(InventoryItem.fromMap).toList();
  }

  Future<InventoryItem?> getItemById(String id) async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return InventoryItem.fromMap(rows.first);
  }

  Future<void> insertItem(InventoryItem item) async {
    final db = await database;

    try {
      await db.insert(_tableName, {
        ...item.toMap(),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.abort);
    } on DatabaseException catch (error) {
      throw _mapDatabaseException(error);
    }
  }

  Future<InventoryItem> createItem({
    required String name,
    required String code,
    required String location,
    required String status,
  }) async {
    final item = InventoryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      code: code.trim(),
      location: location.trim(),
      status: status.trim(),
    );

    await insertItem(item);
    return item;
  }

  Future<void> updateItem(InventoryItem item) async {
    final db = await database;

    try {
      final updatedRows = await db.update(
        _tableName,
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      if (updatedRows == 0) {
        throw InventoryDatabaseException('Item nao encontrado para atualizar.');
      }
    } on DatabaseException catch (error) {
      throw _mapDatabaseException(error);
    }
  }

  Future<bool> deleteItem(String id) async {
    final db = await database;

    final deletedRows = await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return deletedRows > 0;
  }

  Future<void> close() async {
    if (_database == null) {
      return;
    }

    await _database!.close();
    _database = null;
  }

  InventoryDatabaseException _mapDatabaseException(DatabaseException error) {
    final message = error.toString().toLowerCase();

    if (message.contains('unique constraint failed')) {
      if (message.contains('inventory_items.code')) {
        return InventoryDatabaseException(
          'Ja existe um item com esse patrimonio.',
        );
      }

      if (message.contains('inventory_items.id')) {
        return InventoryDatabaseException('ID de item duplicado.');
      }
    }

    if (message.contains('not null constraint failed')) {
      return InventoryDatabaseException(
        'Preencha todos os campos obrigatorios.',
      );
    }

    return InventoryDatabaseException(
      'Erro ao acessar o banco de dados local.',
    );
  }
}
