import 'package:flutter/material.dart';
import '../helper/colors.dart';
import '../helper/formatter.dart';

class RecentTransactions extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final String currencySymbol;
  final VoidCallback onViewAll;

  const RecentTransactions({
    super.key,
    required this.transactions,
    required this.currencySymbol,
    required this.onViewAll,
  });

  String _formatCurrency(double amount, bool isIncome) {
    final formattedAmount = '$currencySymbol ${amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
    
    return '${isIncome ? '+' : '-'}$formattedAmount';
  }

  Widget _buildFormattedDate(String dateString) {
    return FutureBuilder<String>(
      future: Formatter.formatDateFromString(dateString),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }
        return Text(
          snapshot.data ?? dateString,
          style: const TextStyle(fontFamily: 'RobotoSlab'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentWidget = transactions.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Transactions Header dengan More button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoSlab',
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Row(
                children: [
                  Text('More'),
                  Icon(Icons.arrow_forward_ios, size: 12),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        recentWidget.isEmpty
            ? _buildEmptyState(context)
            : _buildTransactionsList(context, recentWidget),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appColors.lightGreyCard, 
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.receipt, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No transactions yet',
              style: TextStyle(fontFamily: 'RobotoSlab'),
            ),
            Text(
              'Add your first transaction',
              style: TextStyle(fontFamily: 'RobotoSlab'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, List<Map<String, dynamic>> transactions) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Column(
      children: transactions.asMap().entries.map((entry) {
        final transaction = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: transaction['isIncome'] 
                        ? Color.fromRGBO(76, 175, 80, 0.1)
                        : Color.fromRGBO(244, 67, 54, 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    transaction['isIncome'] 
                        ? Icons.arrow_circle_up 
                        : Icons.arrow_circle_down,
                    color: transaction['isIncome'] 
                        ? Colors.green 
                        : Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Transaction details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deskripsi transaksi
                      Text(
                        transaction['description'],
                        style: TextStyle(
                          fontFamily: 'RobotoSlab',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: appColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _buildFormattedDate(transaction['date']),
                      const SizedBox(height: 6),
                      
                      // Kategori
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: appColors.badge,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          transaction['category'],
                          style: TextStyle(
                            fontFamily: 'RobotoSlab',
                            fontSize: 11,
                            color: appColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(transaction['amount'], transaction['isIncome']),
                      style: TextStyle(
                        color: transaction['isIncome'] ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RobotoSlab',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: transaction['isIncome'] 
                            ? Color.fromRGBO(76, 175, 80, 0.1)
                            : Color.fromRGBO(244, 67, 54, 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction['isIncome'] ? 'Income' : 'Expense',
                        style: TextStyle(
                          fontFamily: 'RobotoSlab',
                          fontSize: 10,
                          color: transaction['isIncome'] 
                              ? Colors.green 
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}