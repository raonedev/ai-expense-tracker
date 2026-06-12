import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category/category_model.dart';
import '../view_models/category_view_model.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  // Local UI state to filter the list view ('expense' or 'income')
  String _selectedViewType = 'expense';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryViewModelProvider);
    final theme = Theme.of(context);

    // 🟢 Filter categories dynamically based on explicit type property
    final List<CategoryModel> filteredCategories = state.categories.where((
      category,
    ) {
      return category.type == _selectedViewType;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 26),
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : state.errorMessage != null
          ? Center(child: Text(state.errorMessage!))
          : CustomScrollView(
              slivers: [
                // 1. iOS Styled Segmented Switcher Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        children: [
                          _buildSegmentButton('expense', 'Expenses', theme),
                          _buildSegmentButton('income', 'Income', theme),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      bottom: 8.0,
                      top: 8.0,
                    ),
                    child: Text(
                      _selectedViewType == 'income'
                          ? 'INCOME CATEGORIES'
                          : 'EXPENSE CATEGORIES',
                      style: theme.listTileTheme.subtitleTextStyle?.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                // 2. Filtered Categories List
                filteredCategories.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text('No custom categories created yet.'),
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
                            final category = filteredCategories[index];
                            final categoryColor = Color(
                              int.parse(category.color),
                            );

                            return Column(
                              children: [
                                Dismissible(
                                  key: Key(
                                    'cat_${category.id}_${category.name}',
                                  ),
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
                                  // Confirm or handle the swipe dismissal process
                                  onDismissed: (_) {
                                    if (category.id != null) {
                                      ref
                                          .read(
                                            categoryViewModelProvider.notifier,
                                          )
                                          .removeCategory(category.id!);
                                    }
                                  },
                                  child: Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: categoryColor
                                            .withAlpha(30),
                                        child: Icon(
                                          _getIconData(category.icon),
                                          color: categoryColor,
                                        ),
                                      ),
                                      title: Text(category.name),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: theme.disabledColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          }, childCount: filteredCategories.length),
                        ),
                      ),
              ],
            ),
    );
  }

  // Segmented Control Button Builder
  Widget _buildSegmentButton(String type, String label, ThemeData theme) {
    final isSelected = _selectedViewType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedViewType = type),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.cardTheme.color : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: isSelected
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
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? (type == 'expense'
                        ? theme.colorScheme.error
                        : const Color(0xFF34C759))
                  : theme.disabledColor,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'fastfood':
        return Icons.fastfood_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'flight':
        return Icons.flight_rounded;
      case 'build':
        return Icons.build_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'laptop':
        return Icons.laptop_chromebook_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  // 3. Dialog with explicit Type Picker selection
  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    String newCategoryType = 'expense'; // Local dialog tracker

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final theme = Theme.of(context);
          return AlertDialog(
            title: const Text('New Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown to choose where this category is mapped
                DropdownButtonFormField<String>(
                  value: newCategoryType,
                  dropdownColor: theme.cardTheme.color,
                  decoration: const InputDecoration(labelText: 'Category Type'),
                  items: const [
                    DropdownMenuItem(value: 'expense', child: Text('Expense')),
                    DropdownMenuItem(value: 'income', child: Text('Income')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => newCategoryType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g., Side Hustle',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    // Assign customized systemic layouts based on type choice
                    final iconName = newCategoryType == 'income'
                        ? 'trending_up'
                        : 'shopping_bag';
                    final colorHex = newCategoryType == 'income'
                        ? '0xFF34C759'
                        : '0xFFFF3B30';

                    // to prevent everything from saving as an expense default.
                    ref
                        .read(categoryViewModelProvider.notifier)
                        .addCategory(name, iconName, colorHex, newCategoryType);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
}
