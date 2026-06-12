import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/expenses/expense_model.dart';

part 'expense_state.freezed.dart';

@freezed
abstract class ExpenseState with _$ExpenseState {
  const factory ExpenseState({
    @Default(true) bool isLoading,
    @Default([]) List<ExpenseModel> expenses,
    @Default(0.0) double totalAmount,
    String? errorMessage,
  }) = _ExpenseState;
}