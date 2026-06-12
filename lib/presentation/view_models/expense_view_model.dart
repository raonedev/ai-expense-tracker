import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/providers/providers.dart';
import '../../data/models/expenses/expense_model.dart';
import 'expense_state.dart';

class ExpenseViewModel extends StateNotifier<ExpenseState> {
  final Ref _ref;

  ExpenseViewModel(this._ref) : super(const ExpenseState()) {
    loadExpenses();
  }

  /// Fetches all expenses from the repository and calculates the total sum
  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = _ref.read(expenseRepositoryProvider);
      final list = await repo.getAllExpenses();

      // Calculate real net balance based on cashflow type
      double total = 0.0;
      for (var item in list) {
        if (item.type == 'income') {
          total += item.amount;
        } else {
          total -= item.amount; // Deduct if it's an expense
        }
      }

      state = state.copyWith(
        isLoading: false,
        expenses: list,
        totalAmount: total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Adds a new expense item and refreshes the data stack
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final repo = _ref.read(expenseRepositoryProvider);
      await repo.insertExpense(expense);
      await loadExpenses(); // Refresh the visible stack
    } catch (e) {
      state = state.copyWith(errorMessage: 'Could not save expense.');
    }
  }

  /// Removes an expense by its ID
  Future<void> removeExpense(int id) async {
    try {
      final repo = _ref.read(expenseRepositoryProvider);
      await repo.deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Could not delete item.');
    }
  }
}

// ─── Global View Model Provider ──────────────────────────────────────────────
final expenseViewModelProvider =
    StateNotifierProvider<ExpenseViewModel, ExpenseState>((ref) {
      return ExpenseViewModel(ref);
    });
