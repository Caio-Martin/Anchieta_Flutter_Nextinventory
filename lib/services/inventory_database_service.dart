import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/inventory_item.dart';
import '../services/auth_service.dart';

// https://www.reddit.com/r/ProgrammerHumor/comments/rnr9h4/bomb_has_been_planted/?tl=pt-br

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
  // Versão 2: adiciona coluna created_by para isolamento por usuário.
  static const _databaseVersion = 2;
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
            created_at INTEGER NOT NULL,
            created_by TEXT NOT NULL DEFAULT ''
          )
        ''');

        await db.execute(
          'CREATE INDEX idx_inventory_items_created_at ON $_tableName (created_at DESC)',
        );
        await db.execute(
          'CREATE INDEX idx_inventory_items_created_by ON $_tableName (created_by)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Migração v1 → v2: adicionar coluna created_by
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE $_tableName ADD COLUMN created_by TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_inventory_items_created_by ON $_tableName (created_by)',
          );
        }
      },
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Username do usuário atualmente autenticado.
  String get _currentUser => AuthService.currentUser;

  // ── Leitura ──────────────────────────────────────────────────────────────

  /// Retorna apenas os itens criados pelo usuário logado.
  Future<List<InventoryItem>> getItems() async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'created_by = ?',
      whereArgs: [_currentUser],
      orderBy: 'created_at DESC',
    );

    return rows.map(InventoryItem.fromMap).toList();
  }

  /// Busca um item pelo ID, respeitando o escopo do usuário logado.
  Future<InventoryItem?> getItemById(String id) async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'id = ? AND created_by = ?',
      whereArgs: [id, _currentUser],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return InventoryItem.fromMap(rows.first);
  }

  // ── Escrita ──────────────────────────────────────────────────────────────

  Future<void> insertItem(InventoryItem item) async {
    final db = await database;

    try {
      await db.insert(_tableName, {
        ...item.toMap(),
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'created_by': _currentUser,
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
    // ID gerado por timestamp em microsegundos: único globalmente,
    // independente do usuário que está criando o item.
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

  /// Atualiza um item — apenas se ele pertencer ao usuário logado.
  Future<void> updateItem(InventoryItem item) async {
    final db = await database;

    try {
      final updatedRows = await db.update(
        _tableName,
        item.toMap(),
        where: 'id = ? AND created_by = ?',
        whereArgs: [item.id, _currentUser],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      if (updatedRows == 0) {
        throw InventoryDatabaseException('Item nao encontrado para atualizar.');
      }
    } on DatabaseException catch (error) {
      throw _mapDatabaseException(error);
    }
  }

  /// Exclui um item — apenas se ele pertencer ao usuário logado.
  Future<bool> deleteItem(String id) async {
    final db = await database;

    final deletedRows = await db.delete(
      _tableName,
      where: 'id = ? AND created_by = ?',
      whereArgs: [id, _currentUser],
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
