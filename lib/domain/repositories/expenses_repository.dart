
import '../../data/models/expenses/expense_model.dart';

abstract class ExpenseRepository {
  /// Fetches all recorded expenses
  Future<List<ExpenseModel>> getAllExpenses();

  /// Fetches a single expense entry by its ID
  Future<ExpenseModel?> getExpenseById(int id);

  /// Fetches expenses belonging to a specific category
  Future<List<ExpenseModel>> getExpensesByCategory(int categoryId);

  /// Inserts a new expense into the database
  Future<int> insertExpense(ExpenseModel expense);

  /// Updates an existing expense entry
  Future<int> updateExpense(ExpenseModel expense);

  /// Deletes an expense entry by its ID
  Future<int> deleteExpense(int id);
}