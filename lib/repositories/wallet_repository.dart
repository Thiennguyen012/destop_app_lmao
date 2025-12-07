import '../models/wallet.dart';
import '../database/database_helper.dart';

class WalletRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> addWallet(Wallet wallet) async {
    final db = await _dbHelper.database;
    return await db.insert('wallets', wallet.toMap());
  }

  Future<List<Wallet>> getAllWallets() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('wallets', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Wallet.fromMap(maps[i]));
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
    final result =
        await db.rawQuery('SELECT SUM(balance) as total FROM wallets');
    return (result[0]['total'] as num?)?.toDouble() ?? 0.0;
  }
}
