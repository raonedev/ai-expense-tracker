import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../view_models/category_view_model.dart';
import '../view_models/expense_view_model.dart';
import '../../data/models/expenses/expense_model.dart';
import '../view_models/reciept/receipt_scan_view_model.dart';

class ReceiptScanScreen extends ConsumerStatefulWidget {
  const ReceiptScanScreen({super.key});

  @override
  ConsumerState<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends ConsumerState<ReceiptScanScreen> {
  File? _image;
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  int? _selectedCategoryId;
  String _selectedType = 'expense';
  String? _extractedDate;

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickAndScan(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return;

    setState(() => _image = File(picked.path));

    final result = await ref.read(receiptScanProvider.notifier).scan(File(picked.path));
    if (result == null) return;

    final categories = ref.read(categoryViewModelProvider).categories;

    setState(() {
      _merchantController.text = result.merchantName ?? '';
      _amountController.text = result.amount?.toStringAsFixed(2) ?? '';
      _extractedDate = result.date;

      if (result.category != null) {
        final match = categories.where((c) => c.name == result.category && c.type == 'expense').firstOrNull;
        _selectedCategoryId = match?.id;
      }
      _selectedCategoryId ??= categories.where((c) => c.type == 'expense').firstOrNull?.id;
    });
  }

  void _save() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0 || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill amount and category')),
      );
      return;
    }

    final categories = ref.read(categoryViewModelProvider).categories;
    final category = categories.firstWhere((c) => c.id == _selectedCategoryId);

    ref.read(expenseViewModelProvider.notifier).addExpense(
          ExpenseModel(
            title: _merchantController.text.isNotEmpty ? _merchantController.text : category.name,
            amount: amount,
            type: _selectedType,
            categoryId: _selectedCategoryId!,
            date: _extractedDate ?? DateTime.now().toIso8601String(),
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(receiptScanProvider);
    final categories = ref.watch(categoryViewModelProvider).categories;
    final filteredCategories = categories.where((c) => c.type == _selectedType).toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Receipt')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview / Pick Area
            GestureDetector(
              onTap: () => _showSourcePicker(),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.disabledColor.withOpacity(0.3)),
                ),
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.document_scanner_outlined, size: 48, color: theme.disabledColor),
                          const SizedBox(height: 8),
                          Text('Tap to scan receipt', style: TextStyle(color: theme.disabledColor)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            if (scanState.isScanning)
              const Center(child: CircularProgressIndicator.adaptive())
            else if (_image != null && scanState.result == null && scanState.error == null)
              const SizedBox.shrink()
            else if (scanState.error != null)
              Text(scanState.error!, style: TextStyle(color: theme.colorScheme.error)),

            if (scanState.result != null || _image != null) ...[
              const SizedBox(height: 20),

              // Type Switcher
              _buildLabel('TYPE', theme),
              const SizedBox(height: 6),
              _buildTypeSwitcher(theme),
              const SizedBox(height: 16),

              // Category
              _buildLabel('CATEGORY', theme),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedCategoryId,
                    isExpanded: true,
                    dropdownColor: theme.cardTheme.color,
                    hint: const Text('Select Category'),
                    items: filteredCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Merchant
              _buildLabel('MERCHANT', theme),
              const SizedBox(height: 6),
              _buildField(_merchantController),
              const SizedBox(height: 16),

              // Amount
              _buildLabel('AMOUNT', theme),
              const SizedBox(height: 6),
              _buildField(_amountController, prefix: '\$ ', keyboard: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 16),

              // Date
              if (_extractedDate != null) ...[
                _buildLabel('DATE', theme),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(8)),
                  child: Text(_extractedDate!.substring(0, 10)),
                ),
                const SizedBox(height: 24),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _save,
                  child: const Text('Save Expense'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () { Navigator.pop(context); _pickAndScan(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () { Navigator.pop(context); _pickAndScan(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) => Text(
        text,
        style: theme.listTileTheme.subtitleTextStyle?.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
      );

  Widget _buildField(TextEditingController controller, {String? prefix, TextInputType? keyboard}) => TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).cardTheme.color,
          prefixText: prefix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      );

  Widget _buildTypeSwitcher(ThemeData theme) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(9)),
        child: Row(
          children: ['expense', 'income'].map((type) {
            final isSelected = _selectedType == type;
            final color = type == 'expense' ? theme.colorScheme.error : const Color(0xFF34C759);
            return Expanded(
              child: InkWell(
                onTap: () => setState(() {
                  _selectedType = type;
                  _selectedCategoryId = ref.read(categoryViewModelProvider).categories.where((c) => c.type == type).firstOrNull?.id;
                }),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.cardTheme.color : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    type[0].toUpperCase() + type.substring(1),
                    style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? color : theme.disabledColor),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
}