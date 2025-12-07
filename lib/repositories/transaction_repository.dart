import '../models/transaction.dart';
import '../database/database_helper.dart';
import '../services/auth_service.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();

  Future<int> addTransaction(TransactionModel transaction) async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    Map<String, dynamic> map = transaction.toMap();
    map['userId'] = userId;
    return await db.insert('transactions', map);
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return [];

    final List<Map<String, dynamic>> maps = await db.query('transactions',
        where: 'userId = ?', whereArgs: [userId], orderBy: 'date DESC');
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'userId = ? AND type = ?',
      whereArgs: [userId, type],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalIncome() async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return 0.0;

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE userId = ? AND type = ?',
      [userId, 'income'],
    );
    return (result[0]['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalExpense() async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return 0.0;

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE userId = ? AND type = ?',
      [userId, 'expense'],
    );
    return (result[0]['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getBalanceByMonth(int month, int year) async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return 0.0;

    final result = await db.rawQuery(
      '''SELECT 
         SUM(CASE WHEN type = ? THEN amount ELSE 0 END) as income,
         SUM(CASE WHEN type = ? THEN amount ELSE 0 END) as expense
         FROM transactions
         WHERE userId = ? AND strftime('%m', date) = ? AND strftime('%Y', date) = ?''',
      [
        'income',
        'expense',
        userId,
        month.toString().padLeft(2, '0'),
        year.toString()
      ],
    );
    final income = (result[0]['income'] as num?)?.toDouble() ?? 0.0;
    final expense = (result[0]['expense'] as num?)?.toDouble() ?? 0.0;
    return income - expense;
  }
}
