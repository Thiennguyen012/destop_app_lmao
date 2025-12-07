import '../models/category.dart';
import '../database/database_helper.dart';
import '../services/auth_service.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return [];

    final List<Map<String, dynamic>> maps = await db.query('categories',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'type ASC, name ASC');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'userId = ? AND type = ?',
      whereArgs: [userId, type],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> addCategory(Category category) async {
    final db = await _dbHelper.database;
    final userId = AuthService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    Map<String, dynamic> map = category.toMap();
    map['userId'] = userId;
    return await db.insert('categories', map);
  }

  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
