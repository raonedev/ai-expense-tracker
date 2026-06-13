import 'dart:io';

import 'package:expense_tracker/presentation/views/category_screen.dart';
import 'package:expense_tracker/presentation/views/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/receipt_scan_service.dart';
import '../view_models/category_view_model.dart';
import '../view_models/expense_view_model.dart';
import '../../data/models/expenses/expense_model.dart';
import '../view_models/reciept/receipt_scan_view_model.dart';
import 'analytics_screen.dart';
import 'receipt_scan_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseViewModelProvider);
    final theme = Theme.of(context);
    ref.read(categoryViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.bar_chart_rounded),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
          ),
        ),
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CategoryScreen()),
              );
              // _showAddTransactionDialog(context, ref);
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment:
            MainAxisAlignment.center, // Keeps both buttons centered together
        mainAxisSize:
            MainAxisSize.min, // Shrinks the row size to fit only the buttons
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: Size(100, 60),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            onPressed: () {
              _showAddTransactionDialog(context, ref);
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 60, child: VerticalDivider(color: Colors.grey)),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: Size(100, 60),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.all(Radius.zero
                ),
              ),
            ),
            child: Icon(Icons.chat),
          ),
          SizedBox(height: 60, child: VerticalDivider(color: Colors.grey)),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReceiptScanScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: Size(100, 60),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
            child: Icon(Icons.photo),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : state.errorMessage != null
          ? Center(child: Text(state.errorMessage!))
          : CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                //Total Card Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL SPENDING',
                            style: theme.listTileTheme.subtitleTextStyle
                                ?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${state.totalAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: theme.appBarTheme.titleTextStyle?.color,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Segmented Grouped List Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Text(
                      'RECENT TRANSACTIONS',
                      style: theme.listTileTheme.subtitleTextStyle?.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                // Expenses List Element
                state.expenses.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text('No transactions registered yet.'),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final expense = state.expenses[index];
                            final isIncome = expense.type == 'income';
                            return Column(
                              children: [
                                Dismissible(
                                  key: Key(expense.id.toString()),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.error,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (_) {
                                    if (expense.id != null) {
                                      ref
                                          .read(
                                            expenseViewModelProvider.notifier,
                                          )
                                          .removeExpense(expense.id!);
                                    }
                                  },
                                  child: Card(
                                    child: ListTile(
                                      title: Text(expense.title),
                                      subtitle: Text(
                                        expense.date.substring(0, 10),
                                      ),
                                      trailing: Text(
                                        isIncome
                                            ? '+\$${expense.amount.toStringAsFixed(2)}'
                                            : '-\$${expense.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          // iOS Green for Income, Default primary text/dark color for Expense
                                          color: isIncome
                                              ? const Color(0xFF34C759)
                                              : theme
                                                    .appBarTheme
                                                    .titleTextStyle
                                                    ?.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ), // Gap mimic iOS grouped separator
                              ],
                            );
                          }, childCount: state.expenses.length),
                        ),
                      ),
              ],
            ),
    );
  }

  void _showAddTransactionDialog(
    BuildContext context,
    WidgetRef ref, {
    ReceiptScanResult? prefill,
  }) {
    final amountController = TextEditingController(
      text: prefill?.amount?.toStringAsFixed(2) ?? '',
    );
    final merchantController = TextEditingController(
      text: prefill?.merchantName ?? '',
    );
    String selectedType = 'expense';
    final categoryState = ref.read(categoryViewModelProvider);
    final categories = categoryState.categories;

    int? selectedCategoryId;

    // Auto-match prefilled category name
    if (prefill?.category != null) {
      final match = categories
          .where((c) => c.name == prefill!.category && c.type == 'expense')
          .firstOrNull;
      selectedCategoryId = match?.id;
    }
    selectedCategoryId ??= categories
        .where((c) => c.type == 'expense')
        .firstOrNull
        ?.id;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final filteredCategories = categories
                .where((c) => c.type == selectedType)
                .toList();

            return AlertDialog(
              title: const Text('New Transaction'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scan Receipt Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.document_scanner_outlined),
                        label: const Text('Scan Receipt'),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked == null) return;

                          if (!context.mounted) return;
                          Navigator.pop(context); // close current dialog

                          final result = await ref
                              .read(receiptScanProvider.notifier)
                              .scan(File(picked.path));
                          if (!context.mounted) return;

                          if (result == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ref.read(receiptScanProvider).error ??
                                      'Scan failed',
                                ),
                              ),
                            );
                            _showAddTransactionDialog(context, ref);
                          } else {
                            _showAddTransactionDialog(
                              context,
                              ref,
                              prefill: result,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Merchant Field
                    Text(
                      'MERCHANT',
                      style: theme.listTileTheme.subtitleTextStyle?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: merchantController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Type Switcher
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setDialogState(() {
                                selectedType = 'expense';
                                selectedCategoryId = categories
                                    .where((c) => c.type == 'expense')
                                    .firstOrNull
                                    ?.id;
                              }),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedType == 'expense'
                                      ? theme.cardTheme.color
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  'Expense',
                                  style: TextStyle(
                                    fontWeight: selectedType == 'expense'
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: selectedType == 'expense'
                                        ? theme.colorScheme.error
                                        : theme.disabledColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setDialogState(() {
                                selectedType = 'income';
                                selectedCategoryId = categories
                                    .where((c) => c.type == 'income')
                                    .firstOrNull
                                    ?.id;
                              }),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedType == 'income'
                                      ? theme.cardTheme.color
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  'Income',
                                  style: TextStyle(
                                    fontWeight: selectedType == 'income'
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: selectedType == 'income'
                                        ? const Color(0xFF34C759)
                                        : theme.disabledColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Dropdown
                    Text(
                      'CATEGORY',
                      style: theme.listTileTheme.subtitleTextStyle?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedCategoryId,
                          isExpanded: true,
                          dropdownColor: theme.cardTheme.color,
                          hint: const Text('Select Category'),
                          items: filteredCategories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setDialogState(() => selectedCategoryId = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount Field
                    Text(
                      'AMOUNT',
                      style: theme.listTileTheme.subtitleTextStyle?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      autofocus: prefill == null,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        prefixText: '\$ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(amountController.text) ?? 0.0;
                    if (amount > 0 && selectedCategoryId != null) {
                      final chosenCategory = categories.firstWhere(
                        (c) => c.id == selectedCategoryId,
                      );
                      ref
                          .read(expenseViewModelProvider.notifier)
                          .addExpense(
                            ExpenseModel(
                              title: merchantController.text.isNotEmpty
                                  ? merchantController.text
                                  : chosenCategory.name,
                              amount: amount,
                              type: selectedType,
                              categoryId: selectedCategoryId!,
                              date:
                                  prefill?.date ??
                                  DateTime.now().toIso8601String(),
                              createdAt: DateTime.now().toIso8601String(),
                            ),
                          );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
