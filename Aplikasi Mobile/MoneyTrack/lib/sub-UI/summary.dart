import 'package:flutter/material.dart';
import '../helper/colors.dart';
// import 'currency_helper.dart';
import 'chart.dart';

class SummaryPage extends StatefulWidget {
  final double totalIncome;
  final double totalIncomeAllTime;
  final double totalExpense;
  final double totalExpenseAllTime;
  final String selectedFilter;
  final List<String> filters;
  final Function(String) onFilterChanged;
  final String currencySymbol;

  const SummaryPage({
    super.key,
    required this.totalIncome,
    required this.totalIncomeAllTime,
    required this.totalExpense,
    required this.totalExpenseAllTime,
    required this.selectedFilter,
    required this.filters,
    required this.onFilterChanged,
    required this.currencySymbol,
  });

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  void initState() {
    super.initState();
  }

  String _formatSimpleCurrency(double amount, String currencySymbol) {
    return '$currencySymbol ${amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header dengan filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.selectedFilter} Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoSlab',
                color: appColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.filters.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  label: Text(
                    filter,
                    style: const TextStyle(fontFamily: 'RobotoSlab'),
                  ),
                  selected: widget.selectedFilter == filter,
                  onSelected: (selected) {
                    widget.onFilterChanged(filter);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Summary Card dengan Chart
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Total Income & Expense
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Total Income',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: 'RobotoSlab',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _formatSimpleCurrency(widget.totalIncomeAllTime, widget.currencySymbol),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontFamily: 'RobotoSlab',
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Total Expense',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: 'RobotoSlab',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _formatSimpleCurrency(widget.totalExpenseAllTime, widget.currencySymbol),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontFamily: 'RobotoSlab',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Donut Chart dengan legend di dalamnya
                DonutChart(
                  income: widget.totalIncome,
                  expense: widget.totalExpense,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}