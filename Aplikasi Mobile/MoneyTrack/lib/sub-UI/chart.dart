import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../helper/currency_helper.dart';

class DonutChart extends StatelessWidget {
  final double income;
  final double expense;

  const DonutChart({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final total = income + expense;
    
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  startDegreeOffset: -90,
                  sections: [
                    if (income > 0)
                      PieChartSectionData(
                        color: Colors.green,
                        value: income,
                        title: '${((income / total) * 100).toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (expense > 0)
                      PieChartSectionData(
                        color: Colors.red,
                        value: expense,
                        title: '${((expense / total) * 100).toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (total == 0)
                      PieChartSectionData(
                        color: Colors.grey,
                        value: 1,
                        title: 'No Data',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        // Vertical Legend
        Column(
          children: [
            // Income Legend
            _buildLegendItem(
              color: Colors.green,
              label: 'Income',
              amount: income,
              isIncome: true,
            ),
            const SizedBox(height: 5),
            // Expense Legend
            _buildLegendItem(
              color: Colors.red,
              label: 'Expense',
              amount: expense,
              isIncome: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem({
  required Color color,
  required String label,
  required double amount,
  required bool isIncome,
}) {
  return FutureBuilder<String>(
    future: _formatCurrency(amount),
    builder: (context, snapshot) {
      final formattedAmount = snapshot.data ?? 'Rp 0';
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isIncome ? Icons.circle : Icons.circle,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            formattedAmount,
            style: TextStyle(
              fontSize: 16,
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    },
  );
}

  Future<String> _formatCurrency(double amount) async {
    return await CurrencyHelper.formatCurrency(amount);
  }
}