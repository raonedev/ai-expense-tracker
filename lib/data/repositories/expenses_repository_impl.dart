import '../../core/helper/db_helper.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../models/expenses/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final DBHelper _dbHelper;

  ExpenseRepositoryImpl(this._dbHelper);

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    // Orders expenses from newest to oldest by default
    final List<Map<String, dynamic>> maps = await _dbHelper.query(
      'expenses', 
      orderBy: 'date DESC',
    );
    return maps.map((json) => ExpenseModel.fromJson(json)).toList();
  }

  @override
  Future<ExpenseModel?> getExpenseById(int id) async {
    final List<Map<String, dynamic>> maps = await _dbHelper.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ExpenseModel.fromJson(maps.first);
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory(int categoryId) async {
    final List<Map<String, dynamic>> maps = await _dbHelper.query(
      'expenses',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return maps.map((json) => ExpenseModel.fromJson(json)).toList();
  }

  @override
  Future<int> insertExpense(ExpenseModel expense) async {
    return await _dbHelper.insert('expenses', expense.toJson());
  }

  @override
  Future<int> updateExpense(ExpenseModel expense) async {
    if (expense.id == null) {
      throw ArgumentError('Cannot update an expense without an ID.');
    }
    return await _dbHelper.update('expenses', expense.toJson(), expense.id!);
  }

  @override
  Future<int> deleteExpense(int id) async {
    return await _dbHelper.delete('expenses', id);
  }
}