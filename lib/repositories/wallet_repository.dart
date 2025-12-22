import '../models/wallet.dart';
import '../database/database_helper.dart';
import '../services/auth_service.dart';

class WalletRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> addWallet(Wallet wallet) async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    Map<String, dynamic> map = wallet.toMap();
    map['userId'] = userId;
    return await db.insert('wallets', map);
  }

  Future<List<Wallet>> getAllWallets() async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'wallets',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Wallet.fromMap(maps[i]));
  }

  Future<Wallet?> getWalletById(int walletId) async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      'wallets',
      where: 'id = ? AND userId = ?',
      whereArgs: [walletId, userId],
      limit: 1,
    );
    return maps.isNotEmpty ? Wallet.fromMap(maps[0]) : null;
  }

  Future<int> updateWallet(Wallet wallet) async {
    final db = await _dbHelper.database;
    return await db.update(
      'wallets',
      wallet.toMap(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  Future<int> deleteWallet(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'wallets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalBalance() async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return 0.0;

    final result = await db.rawQuery(
      'SELECT SUM(balance) as total FROM wallets WHERE userId = ?',
      [userId],
    );
    return (result[0]['total'] as num?)?.toDouble() ?? 0.0;
  }
}
