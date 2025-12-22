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
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_management.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Thêm cột walletId vào bảng transactions
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN walletId INTEGER',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tạo bảng Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Tạo bảng Wallets
    await db.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        name TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        currency TEXT NOT NULL DEFAULT 'VND',
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Tạo bảng Categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Tạo bảng Transactions
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        walletId INTEGER,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (walletId) REFERENCES wallets(id) ON DELETE SET NULL
      )
    ''');

    // Thêm các category mặc định
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    List<Map<String, dynamic>> defaultCategories = [
      {'userId': 1, 'name': 'Lương', 'type': 'income', 'icon': '💼'},
      {'userId': 1, 'name': 'Thưởng', 'type': 'income', 'icon': '🎁'},
      {'userId': 1, 'name': 'Đầu tư', 'type': 'income', 'icon': '📈'},
      {'userId': 1, 'name': 'Ăn uống', 'type': 'expense', 'icon': '🍔'},
      {'userId': 1, 'name': 'Mua sắm', 'type': 'expense', 'icon': '🛍️'},
      {'userId': 1, 'name': 'Giao thông', 'type': 'expense', 'icon': '🚗'},
      {'userId': 1, 'name': 'Điện nước', 'type': 'expense', 'icon': '💡'},
      {'userId': 1, 'name': 'Giáo dục', 'type': 'expense', 'icon': '📚'},
      {'userId': 1, 'name': 'Y tế', 'type': 'expense', 'icon': '🏥'},
      {'userId': 1, 'name': 'Giải trí', 'type': 'expense', 'icon': '🎮'},
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // User Management Methods
  Future<int> registerUser(String email, String password, String name) async {
    final db = await database;
    return await db.insert('users', {
      'email': email,
      'password': password,
      'name': name,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> close() async {
    _database?.close();
    _database = null;
  }
}
