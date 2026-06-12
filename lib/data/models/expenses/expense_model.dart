import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_model.freezed.dart';
part 'expense_model.g.dart';

@freezed
abstract class ExpenseModel with _$ExpenseModel {
  const factory ExpenseModel({
    int? id,
    required String title,
    required double amount,
    @Default('expense') String type, // 'expense' or 'income'
    @JsonKey(name: 'category_id') required int categoryId,
    String? merchant,
    required String date,
    String? note,
    @Default('manual') String source,
    @JsonKey(name: 'receipt_path') String? receiptPath,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _ExpenseModel;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);
}