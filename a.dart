import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'produtos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            preco REAL NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertProduto(String nome, double preco) async {
    final db = await database;
    await db.insert(
      'produtos',
      {'nome': nome, 'preco': preco},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getProdutos() async {
    final db = await database;
    return await db.query('produtos');
  }

  Future<void> updateProduto(int id, String nome, double preco) async {
    final db = await database;
    await db.update(
      'produtos',
      {'nome': nome, 'preco': preco},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteProduto(int id) async {
    final db = await database;
    await db.delete(
      'produtos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
