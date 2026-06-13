import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/receipt_scan_service.dart';
import '../../../data/models/category/category_model.dart';
import 'receipt_scan_state.dart';

final receiptScanProvider = StateNotifierProvider<ReceiptScanViewModel, ReceiptScanState>((ref) {
  return ReceiptScanViewModel(ref);
});

class ReceiptScanViewModel extends StateNotifier<ReceiptScanState> {
  final Ref _ref;
  ReceiptScanViewModel(this._ref) : super(const ReceiptScanState());

  final _service = ReceiptScanService();

  Future<ReceiptScanResult?> scan(File file) async {
    state = state.copyWith(isScanning: true, error: null);

    final categoryRepo = _ref.read(categoryRepositoryProvider);
    final allCategories = await categoryRepo.getAllCategories();
    final expenseCategories = allCategories.where((c) => c.type == 'expense').toList();
    final categoryNames = expenseCategories.map((c) => c.name).toList();

    final result = await _service.scanReceipt(file, categoryNames);

    if (result.rawError != null) {
      state = state.copyWith(isScanning: false, error: result.rawError);
      return null;
    }

    // If AI suggested a new category not in DB, insert it
    if (result.category != null && !categoryNames.contains(result.category)) {
      await categoryRepo.insertCategory(CategoryModel(
        id: null,
        name: result.category!,
        icon: 'receipt',
        color: '0xFF9E9E9E',
        type: 'expense',
      ));
    }

    state = state.copyWith(isScanning: false, result: result);
    return result;
  }

  void reset() => state = const ReceiptScanState();
}