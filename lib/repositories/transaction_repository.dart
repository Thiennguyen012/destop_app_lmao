import '../models/transaction.dart';
import '../database/database_helper.dart';
import '../services/auth_service.dart';
import 'wallet_repository.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final WalletRepository _walletRepository = WalletRepository();

  Future<int> addTransaction(TransactionModel transaction) async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    Map<String, dynamic> map = transaction.toMap();
    map['userId'] = userId;

    // Thêm giao dịch
    final transactionId = await db.insert('transactions', map);

    // Cập nhật số dư ví nếu có walletId
    if (transaction.walletId != null) {
      final wallet =
          await _walletRepository.getWalletById(transaction.walletId!);
      if (wallet != null) {
        double newBalance = wallet.balance;
        if (transaction.type == 'income') {
          newBalance += transaction.amount;
        } else {
          newBalance -= transaction.amount;
        }

        final updatedWallet = wallet.copyWith(balance: newBalance);
        await _walletRepository.updateWallet(updatedWallet);
      }
    }

    return transactionId;
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

    // Normalize dates để chắc chắn include cả ngày cuối
    final start = startDate.toIso8601String().split('T')[0];
    final end = DateTime(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'userId = ? AND date >= ? AND date < ?',
      whereArgs: [
        userId,
        start,
        end,
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

    // Lấy thông tin giao dịch trước khi xóa
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final transaction = TransactionModel.fromMap(maps[0]);

      // Cập nhật số dư ví nếu có walletId
      if (transaction.walletId != null) {
        final wallet =
            await _walletRepository.getWalletById(transaction.walletId!);
        if (wallet != null) {
          double newBalance = wallet.balance;
          if (transaction.type == 'income') {
            newBalance -= transaction.amount;
          } else {
            newBalance += transaction.amount;
          }

          final updatedWallet = wallet.copyWith(balance: newBalance);
          await _walletRepository.updateWallet(updatedWallet);
        }
      }
    }

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

  Future<List<TransactionModel>> getTransactionsByWallet(int walletId) async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'userId = ? AND walletId = ?',
      whereArgs: [userId, walletId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<double> getTotalBalanceByMonth(int month, int year) async {
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

  Future<double> getIncomeTotalByWallet(int walletId) async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return 0.0;

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE userId = ? AND walletId = ? AND type = ?',
      [userId, walletId, 'income'],
    );
    return (result[0]['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getExpenseTotalByWallet(int walletId) async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return 0.0;

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE userId = ? AND walletId = ? AND type = ?',
      [userId, walletId, 'expense'],
    );
    return (result[0]['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getMonthlyIncome(int month, int year) async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return 0.0;

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE userId = ? AND type = ? AND strftime(\'%m\', date) = ? AND strftime(\'%Y\', date) = ?',
      [userId, 'income', month.toString().padLeft(2, '0'), year.toString()],
    );
    return (result[0]['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getMonthlyExpense(int month, int year) async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return 0.0;

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE userId = ? AND type = ? AND strftime(\'%m\', date) = ? AND strftime(\'%Y\', date) = ?',
      [userId, 'expense', month.toString().padLeft(2, '0'), year.toString()],
    );
    return (result[0]['total'] as num?)?.toDouble() ?? 0.0;
  }
}
