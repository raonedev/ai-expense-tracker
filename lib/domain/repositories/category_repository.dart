
import '../../data/models/category/category_model.dart';

abstract class CategoryRepository {
  /// Fetches all available categories 
  Future<List<CategoryModel>> getAllCategories();

  /// Fetches a single category by its ID
  Future<CategoryModel?> getCategoryById(int id);

  /// Allows users to add custom categories
  Future<int> insertCategory(CategoryModel category);

  // Allows users to remove custom categories by ID
  Future<int> deleteCategory(int id);
}