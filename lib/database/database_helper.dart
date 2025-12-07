import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Initialization status tracking
  bool _isInitialized = false;
  DateTime? _initStartTime;
  DateTime? _initEndTime;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    _logInfo('Starting database initialization...');
    _initStartTime = DateTime.now();

    try {
      String path = join(await getDatabasesPath(), 'qlnv.db');
      _logInfo('Database path: $path');

      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );

      _initEndTime = DateTime.now();
      _isInitialized = true;
      final duration = _initEndTime!.difference(_initStartTime!).inMilliseconds;
      _logInfo('Database initialized successfully in ${duration}ms');

      return db;
    } catch (e, stackTrace) {
      _logError('Database initialization failed', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    _logInfo('Creating database tables...');

    // Tạo bảng Wallets
    _logInfo('Creating wallets table');
    await db.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        currency TEXT NOT NULL DEFAULT 'VND',
        createdAt TEXT NOT NULL
      )
    ''');

    // Tạo bảng Categories
    _logInfo('Creating categories table');
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL
      )
    ''');

    // Tạo bảng Transactions
    _logInfo('Creating transactions table');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT
      )
    ''');

    _logInfo('All tables created successfully');

    // Thêm các category mặc định
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    _logInfo('Inserting default categories...');

    List<Map<String, dynamic>> defaultCategories = [
      {'name': 'Lương', 'type': 'income', 'icon': '💼'},
      {'name': 'Thưởng', 'type': 'income', 'icon': '🎁'},
      {'name': 'Đầu tư', 'type': 'income', 'icon': '📈'},
      {'name': 'Ăn uống', 'type': 'expense', 'icon': '🍔'},
      {'name': 'Mua sắm', 'type': 'expense', 'icon': '🛍️'},
      {'name': 'Giao thông', 'type': 'expense', 'icon': '🚗'},
      {'name': 'Điện nước', 'type': 'expense', 'icon': '💡'},
      {'name': 'Giáo dục', 'type': 'expense', 'icon': '📚'},
      {'name': 'Y tế', 'type': 'expense', 'icon': '🏥'},
      {'name': 'Giải trí', 'type': 'expense', 'icon': '🎮'},
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }

    _logInfo('Inserted ${defaultCategories.length} default categories');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
      _logInfo('Database closed successfully');
    }
  }

  // Logging methods
  void _logInfo(String message) {
    print('[DatabaseHelper] $message');
  }

  void _logError(String message, dynamic error, StackTrace stackTrace) {
    print('[DatabaseHelper ERROR] $message: $error');
    print('[DatabaseHelper ERROR] Stack trace: $stackTrace');
  }
}
