import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/expenses_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../helper/db_helper.dart';

//  Base Provider for the Database Helper singleton
final dbHelperProvider = Provider<DBHelper>((ref) {
  return DBHelper();
});

// Provider for the Category Repository Interface
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return CategoryRepositoryImpl(dbHelper);
});

//  Provider for the Expense Repository Interface
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return ExpenseRepositoryImpl(dbHelper);
});