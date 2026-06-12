import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/models/category/category_model.dart';
import '../constants/app_constants.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._();
  static Database? _db;

  DBHelper._();
  factory DBHelper() => _instance;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Create tables
    await db.execute('''
      CREATE TABLE categories (
        id    INTEGER PRIMARY KEY AUTOINCREMENT,
        name  TEXT    NOT NULL UNIQUE,
        icon  TEXT    NOT NULL,
        color TEXT    NOT NULL,
        type  TEXT    NOT NULL DEFAULT 'expense'
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        title         TEXT    NOT NULL,
        amount        REAL    NOT NULL,
        type          TEXT    NOT NULL DEFAULT 'expense', -- 'expense' or 'income'
        category_id   INTEGER NOT NULL,
        merchant      TEXT,
        date          TEXT    NOT NULL,
        note          TEXT,
        source        TEXT    NOT NULL DEFAULT 'manual',
        receipt_path  TEXT,
        created_at    TEXT    NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    // 2. Seed initial categories
    await _seedCategories(db);
  }

  Future<void> _seedCategories(Database db) async {
    final List<CategoryModel> defaultCategories = [
      // Expense Categories (Passing the correct type string matching your newly added column)
      const CategoryModel(
        id: 1,
        name: 'Food',
        icon: 'fastfood',
        color: '0xFFFF9800',
        type: 'expense',
      ),
      const CategoryModel(
        id: 2,
        name: 'Shopping',
        icon: 'shopping_bag',
        color: '0xFFE91E63',
        type: 'expense',
      ),
      const CategoryModel(
        id: 3,
        name: 'Travel',
        icon: 'flight',
        color: '0xFF2196F3',
        type: 'expense',
      ),
      const CategoryModel(
        id: 4,
        name: 'Utilities',
        icon: 'build',
        color: '0xFF607D8B',
        type: 'expense',
      ),
      const CategoryModel(
        id: 5,
        name: 'Entertainment',
        icon: 'movie',
        color: '0xFF9C27B0',
        type: 'expense',
      ),

      // Income Categories
      const CategoryModel(
        id: 6,
        name: 'Salary',
        icon: 'work',
        color: '0xFF4CD964',
        type: 'income',
      ),
      const CategoryModel(
        id: 7,
        name: 'Freelance',
        icon: 'laptop',
        color: '0xFF5AC8FA',
        type: 'income',
      ),
      const CategoryModel(
        id: 8,
        name: 'Investments',
        icon: 'trending_up',
        color: '0xFF5856D6',
        type: 'income',
      ),
    ];

    for (var category in defaultCategories) {
      await db.insert(
        'categories',
        category.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // ─── CRUD helpers ───────────────────────────────────────────────────────────

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    final db = await database;
    return db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }
}
