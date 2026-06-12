import 'package:expense_tracker/presentation/views/category_screen.dart';
import 'package:expense_tracker/presentation/views/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/category_view_model.dart';
import '../view_models/expense_view_model.dart';
import '../../data/models/expenses/expense_model.dart';
import 'analytics_screen.dart';

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
                borderRadius: BorderRadiusGeometry.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
            child: Icon(Icons.all_inclusive_sharp),
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

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();

    // Local state to manage the selected type and category inside the dialog
    String selectedType = 'expense'; // default value
    int? selectedCategoryId;

    // Read available categories from the state manager
    final categoryState = ref.read(categoryViewModelProvider);
    final categories = categoryState.categories;

    // Filter categories to auto-select the first valid one as a default fallback
    // 🟢 FIXED: Auto-select using the explicit type string property instead of guessing by ID ranges
    final initialCategories = categories
        .where((c) => c.type == selectedType)
        .toList();

    if (initialCategories.isNotEmpty) {
      selectedCategoryId = initialCategories.first.id;
    }

    if (initialCategories.isNotEmpty) {
      selectedCategoryId = initialCategories.first.id;
    }

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder lets us mutate local state values cleanly inside a dialog window frame
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);

            // Dynamically filter categories based on the currently selected type
            final filteredCategories = categories.where((c) {
              return c.type == selectedType;
            }).toList();

            return AlertDialog(
              title: const Text('New Transaction'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Segmented Control Switcher (Expense vs Income)
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

                                if (categories.any(
                                  (c) => c.type == 'expense',
                                )) {
                                  selectedCategoryId = categories
                                      .firstWhere((c) => c.type == 'expense')
                                      .id;
                                }
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
                                  boxShadow: selectedType == 'expense'
                                      ? [
                                          const BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ]
                                      : [],
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
                                if (categories.any((c) => c.type == 'income')) {
                                  selectedCategoryId = categories
                                      .firstWhere((c) => c.type == 'income')
                                      .id;
                                }
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
                                  boxShadow: selectedType == 'income'
                                      ? [
                                          const BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ]
                                      : [],
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

                    // 2. Category Selection Dropdown
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
                          items: filteredCategories.map((category) {
                            return DropdownMenuItem<int>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedCategoryId = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Amount Field Input
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
                      autofocus: true,
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
                      // Match transaction title to the selected category name automatically
                      final chosenCategory = categories.firstWhere(
                        (c) => c.id == selectedCategoryId,
                      );

                      ref
                          .read(expenseViewModelProvider.notifier)
                          .addExpense(
                            ExpenseModel(
                              title: chosenCategory
                                  .name, // Auto-assign name from category
                              amount: amount,
                              type: selectedType,
                              categoryId: selectedCategoryId!,
                              date: DateTime.now().toIso8601String(),
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
