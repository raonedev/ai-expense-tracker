import '../../core/helper/db_helper.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final DBHelper _dbHelper;

  CategoryRepositoryImpl(this._dbHelper);

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final List<Map<String, dynamic>> maps = await _dbHelper.query('categories');
    return maps.map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<CategoryModel?> getCategoryById(int id) async {
    final List<Map<String, dynamic>> maps = await _dbHelper.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return CategoryModel.fromJson(maps.first);
  }

  @override
  Future<int> insertCategory(CategoryModel category) async {
    // Converts Freezed model to Map for SQLite injection
    return await _dbHelper.insert('categories', category.toJson());
  }
  
  @override
  Future<int> deleteCategory(int id) async{
    return await _dbHelper.delete('categories', id);
  }
}
