import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/providers/providers.dart';
import '../../data/models/category/category_model.dart';
import 'category_state.dart';

class CategoryViewModel extends StateNotifier<CategoryState> {
  final Ref _ref;

  CategoryViewModel(this._ref) : super(const CategoryState()) {
    loadCategories();
  }

  /// Fetches all categories from the repository
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      final list = await repo.getAllCategories();
      state = state.copyWith(isLoading: false, categories: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load categories: $e',
      );
    }
  }

  /// Inserts a new custom category into the DB and updates the state
  Future<void> addCategory(String name, String icon, String colorHex,String type) async {
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      
      // Creating the model instance (ID can be 0 or null; SQLite auto-increments)
      final newCategory = CategoryModel(
        id: null, 
        name: name,
        icon: icon,
        color: colorHex,
        type: type
      );

      final res = await repo.insertCategory(newCategory);
      await loadCategories(); // Refresh list automatically
    } catch (e) {
      state = state.copyWith(errorMessage: 'Category name must be unique.');
    }
  }

  /// Removes a category by its ID
  Future<void> removeCategory(int id) async {
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      await repo.deleteCategory(id);
      await loadCategories(); // Refresh the list automatically
    } catch (e) {
      // If a foreign key constraint prevents deletion, catch it cleanly here
      state = state.copyWith(
        errorMessage: 'Cannot delete: This category is currently being used by existing transactions.',
      );
      
      // Optional: Clear error message after 3 seconds so the UI recovers
      Future.delayed(const Duration(seconds: 3), () {
        state = state.copyWith(errorMessage: null);
      });
    }
  }
}

// ─── Global Category View Model Provider ─────────────────────────────────────
final categoryViewModelProvider =
    StateNotifierProvider<CategoryViewModel, CategoryState>((ref) {
  return CategoryViewModel(ref);
});