// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) =>
    _ExpenseModel(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String? ?? 'expense',
      categoryId: (json['category_id'] as num).toInt(),
      merchant: json['merchant'] as String?,
      date: json['date'] as String,
      note: json['note'] as String?,
      source: json['source'] as String? ?? 'manual',
      receiptPath: json['receipt_path'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$ExpenseModelToJson(_ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'amount': instance.amount,
      'type': instance.type,
      'category_id': instance.categoryId,
      'merchant': instance.merchant,
      'date': instance.date,
      'note': instance.note,
      'source': instance.source,
      'receipt_path': instance.receiptPath,
      'created_at': instance.createdAt,
    };
