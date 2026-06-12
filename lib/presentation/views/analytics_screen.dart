import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../view_models/expense_view_model.dart';
import '../../data/models/expenses/expense_model.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _timeframe = 'week'; // 'week' or 'month'
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseViewModelProvider);
    final theme = Theme.of(context);

    // 1. Filter transactions matching current Timeframe window
    final filteredTransactions = expenseState.expenses.where((tx) {
      final txDate = DateTime.parse(tx.date);
      if (_timeframe == 'week') {
        final startOfWeek = _focusedDate.subtract(Duration(days: _focusedDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return txDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
               txDate.isBefore(endOfWeek.add(const Duration(seconds: 1)));
      } else {
        return txDate.month == _focusedDate.month && txDate.year == _focusedDate.year;
      }
    }).toList();

    // 2. Prep side-by-side Bar Chart Data
    final List<CashFlowData> barChartData = _generateBarData(filteredTransactions);

    // 3. Prep Category Breakdown Data
    final List<CategoryShareData> pieChartData = _generatePieData(filteredTransactions);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: expenseState.isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : CustomScrollView(
              slivers: [
                // ─── Timeframe Controls ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildSegmentButton('week', 'This Week'),
                            const SizedBox(width: 12),
                            _buildSegmentButton('month', 'This Month'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, size: 16),
                              onPressed: () => _adjustTimeWindow(-1),
                            ),
                            Text(
                              _getDateRangeLabel(),
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, size: 16),
                              onPressed: () => _adjustTimeWindow(1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Chart 1: Side-By-Side Cashflow ───
                SliverToBoxAdapter(
                  child: Container(
                    height: 260,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SfCartesianChart(
                      primaryXAxis: const CategoryAxis(),
                      title: ChartTitle(text: 'Income vs Expenses', textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries<CashFlowData, String>>[
                        ColumnSeries<CashFlowData, String>(
                          name: 'Income',
                          dataSource: barChartData,
                          xValueMapper: (CashFlowData data, _) => data.label,
                          yValueMapper: (CashFlowData data, _) => data.income,
                          color: const Color(0xFF34C759), // iOS Green
                        ),
                        ColumnSeries<CashFlowData, String>(
                          name: 'Expense',
                          dataSource: barChartData,
                          xValueMapper: (CashFlowData data, _) => data.label,
                          yValueMapper: (CashFlowData data, _) => data.expense,
                          color: theme.colorScheme.error, // iOS Red
                        )
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ─── Chart 2: Category Breakdown ───
                SliverToBoxAdapter(
                  child: Container(
                    height: 260,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: pieChartData.isEmpty
                        ? const Center(child: Text('No data recorded for this selection.'))
                        : SfCircularChart(
                            title: ChartTitle(text: 'Spending by Category', textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            legend: const Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap, position: LegendPosition.right),
                            series: <CircularSeries>[
                              DoughnutSeries<CategoryShareData, String>(
                                dataSource: pieChartData,
                                xValueMapper: (CategoryShareData data, _) => data.categoryName,
                                yValueMapper: (CategoryShareData data, _) => data.amount,
                                dataLabelSettings: const DataLabelSettings(isVisible: true),
                                innerRadius: '60%',
                              )
                            ],
                          ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
    );
  }

  // Helper Segmented Tab Builder
  Widget _buildSegmentButton(String type, String title) {
    final isSelected = _timeframe == type;
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _timeframe = type;
          _focusedDate = DateTime.now(); // reset frame back to modern window
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : theme.disabledColor,
            ),
          ),
        ),
      ),
    );
  }

  // Date Shift logic via back/next arrows
  void _adjustTimeWindow(int value) {
    setState(() {
      if (_timeframe == 'week') {
        _focusedDate = _focusedDate.add(Duration(days: value * 7));
      } else {
        _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + value, 1);
      }
    });
  }

  String _getDateRangeLabel() {
    if (_timeframe == 'week') {
      final startOfWeek = _focusedDate.subtract(Duration(days: _focusedDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return "${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month}";
    } else {
      final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${months[_focusedDate.month - 1]} ${_focusedDate.year}";
    }
  }

  // Logic to parse transactions into Side-By-Side totals
  List<CashFlowData> _generateBarData(List<ExpenseModel> items) {
    double incomeTotal = 0.0;
    double expenseTotal = 0.0;

    for (var tx in items) {
      if (tx.type == 'income') {
        incomeTotal += tx.amount;
      } else {
        expenseTotal += tx.amount;
      }
    }
    // Return a list with a single bucket grouping comparing totals side by side
    return [CashFlowData('Total Flows', incomeTotal, expenseTotal)];
  }

  // Logic to accumulate total spending strictly grouped category-wise
  List<CategoryShareData> _generatePieData(List<ExpenseModel> items) {
    final Map<String, double> transformMap = {};

    // Only compute expense allocations for structural charts
    final spendingEntries = items.where((element) => element.type == 'expense');

    for (var tx in spendingEntries) {
      transformMap[tx.title] = (transformMap[tx.title] ?? 0) + tx.amount;
    }

    return transformMap.entries
        .map((entry) => CategoryShareData(entry.key, entry.value))
        .toList();
  }
}

// ─── Internal Data Holder Models For Syncfusion Series Rendering ─────────────
class CashFlowData {
  final String label;
  final double income;
  final double expense;
  CashFlowData(this.label, this.income, this.expense);
}

class CategoryShareData {
  final String categoryName;
  final double amount;
  CategoryShareData(this.categoryName, this.amount);
}