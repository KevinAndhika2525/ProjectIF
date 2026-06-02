import 'package:flutter/material.dart';
import '../helper/colors.dart';
import '../helper/currency_helper.dart';
import '../helper/formatter.dart';
import 'transaction.dart';

class AllTransactionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(int, Map<String, dynamic>)? onUpdate; 
  final Function(int)? onDelete;

  const AllTransactionsPage({
    super.key,
    required this.transactions,
    this.onUpdate,
    this.onDelete,
  });

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  String _selectedTypeFilter = 'All';
  List<String> typeFilters = ['All', 'Income', 'Expense'];
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showActions = false;
  int? _selectedIndex;
  bool _showSearch = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<Map<String, dynamic>> get _filteredTransactions {
    List<Map<String, dynamic>> filtered = List.from(widget.transactions);
    
    // Filter by type
    if (_selectedTypeFilter == 'Income') {
      filtered = filtered.where((transaction) => transaction['isIncome'] == true).toList();
    } else if (_selectedTypeFilter == 'Expense') {
      filtered = filtered.where((transaction) => transaction['isIncome'] == false).toList();
    }
    
    // Filter by date range
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((transaction) {
        final transactionDate = _parseDate(transaction['date']);
        return transactionDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
               transactionDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        final description = (transaction['description'] ?? '').toString().toLowerCase();
        final category = (transaction['category'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return description.contains(query) || category.contains(query);
      }).toList();
    }
    
    return filtered;
  }
  
  // Parsing berbagai format date
  DateTime _parseDate(String dateString) {
    try {
      final slashParts = dateString.split('/');
      if (slashParts.length == 3) {
        return DateTime(
          int.parse(slashParts[2]),
          int.parse(slashParts[1]),
          int.parse(slashParts[0]),
        );
      }
      final dashParts = dateString.split('-');
      if (dashParts.length == 3) {
        int month;
        if (RegExp(r'^\d+$').hasMatch(dashParts[1])) {
          month = int.parse(dashParts[1]);
        } else {
          const monthNames = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
          ];
          month = monthNames.indexWhere((name) => 
            name.toLowerCase() == dashParts[1].toLowerCase()) + 1;
          if (month == 0) month = 1;
        }
        
        return DateTime(
          int.parse(dashParts[2]),
          month,
          int.parse(dashParts[0]),
        );
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return DateTime.now();
  }
  
  Future<String> _formatCurrency(double amount, bool isIncome) async {
    return await CurrencyHelper.formatCurrencyWithSign(amount, isIncome);
  }

  // format time
  String _getTimeFromTransaction(Map<String, dynamic> transaction) {
    if (transaction.containsKey('time') && transaction['time'] is String) {
      final timeStr = transaction['time'] as String;
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          try {
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);
            if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
              return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
            }
          } catch (e) {
            print('Error parsing time from string: $e');
          }
        }
      }
    }
    if (transaction.containsKey('dateTime') && transaction['dateTime'] is DateTime) {
      final dateTime = transaction['dateTime'] as DateTime;
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '00:00';
  }
  
  String _getGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final transactionDate = DateTime(date.year, date.month, date.day);
    
    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return _formatDateForHeader(date);
    }
  }
  
  String _formatDateForHeader(DateTime date) {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }
  
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null 
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
  
  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }
  
  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _showSearch = false;
    });
  }
  
  Map<String, List<Map<String, dynamic>>> _groupTransactionsByDate() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    
    for (final transaction in _filteredTransactions) {
      final transactionDate = _parseDate(transaction['date']);
      final header = _getGroupHeader(transactionDate);
      
      if (!grouped.containsKey(header)) {
        grouped[header] = [];
      }
      grouped[header]!.add(transaction);
    }
    
    return grouped;
  }

  // Fungsi edit transaction
  void _editTransaction(Map<String, dynamic> transaction, int filteredIndex) async {
    int originalIndex = -1;
    
    for (int i = 0; i < widget.transactions.length; i++) {
      final original = widget.transactions[i];
      bool isSame = true;
      final originalAmount = original['amount'] as double? ?? 0.0;
      final transactionAmount = transaction['amount'] as double? ?? 0.0;
      if ((originalAmount - transactionAmount).abs() > 0.001) {
        isSame = false;
      }
      
      // Cek description
      if (isSame && original['description'] != transaction['description']) {
        isSame = false;
      }
      
      // Cek date
      if (isSame && original['date'] != transaction['date']) {
        isSame = false;
      }
      
      // Cek time
      if (isSame && original['time'] != transaction['time']) {
        isSame = false;
      }
      
      // Cek type (income/expense)
      if (isSame && original['isIncome'] != transaction['isIncome']) {
        isSame = false;
      }
      
      if (isSame) {
        originalIndex = i;
        break;
      }
    }
    
    // Jika tidak ditemukan, gunakan filteredIndex sebagai fallback
    if (originalIndex == -1) {
      originalIndex = filteredIndex;
    }
    
    final transactionToEdit = Map<String, dynamic>.from(transaction);
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionPage(
          defaultType: transactionToEdit['isIncome'] ? 'Income' : 'Expense',
          transactionToEdit: transactionToEdit,
        ),
      ),
    );
    
    if (result != null && widget.onUpdate != null && mounted) {
      widget.onUpdate!(originalIndex, result);
      
      setState(() {
        _selectedIndex = null;
      });
    }
  }
  
  void _deleteTransaction(int globalIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Transaction',
          style: TextStyle(fontFamily: 'RobotoSlab', fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to delete this transaction?',
          style: TextStyle(fontFamily: 'RobotoSlab'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'RobotoSlab'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
              if (widget.onDelete != null) {
                int originalIndex = -1;
                final transaction = _filteredTransactions[globalIndex];
                
                for (int i = 0; i < widget.transactions.length; i++) {
                  final original = widget.transactions[i];
                  
                  bool isSame = true;
                  if (original['description'] != transaction['description']) {
                    isSame = false;
                  }
                  if (original['date'] != transaction['date']) {
                    isSame = false;
                  }
                  if (original['amount'] != transaction['amount']) {
                    isSame = false;
                  }
                  
                  if (isSame) {
                    originalIndex = i;
                    break;
                  }
                }
                
                if (originalIndex != -1) {
                  widget.onDelete!(originalIndex);
                } else {
                  widget.onDelete!(globalIndex);
                }
              }
              
              if (mounted) {
                setState(() {
                  _selectedIndex = null;
                });
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'RobotoSlab',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: appColors.dateHeader,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search by description or category...',
                hintStyle: TextStyle(fontFamily: 'RobotoSlab', color: appColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: appColors.unselectedChip,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: Icon(Icons.search, color: appColors.textPrimary),
              ),
              style: const TextStyle(fontFamily: 'RobotoSlab'),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (_) {
                _searchFocusNode.unfocus();
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.close, color: appColors.textPrimary),
            onPressed: () {
              setState(() {
                _showSearch = false;
                _searchQuery = '';
                _searchController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Menampilkan tanggal dengan format
  Widget _buildFormattedDate(String dateString) {
    return FutureBuilder<String>(
      future: Formatter.formatDateFromString(dateString),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('...');
        }
        return Text(
          snapshot.data ?? dateString,
          style: const TextStyle(
            fontFamily: 'RobotoSlab',
          ),
        );
      },
    );
  }

  // Menampilkan waktu transaksi
  Widget _buildTimeDisplay(Map<String, dynamic> transaction) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final timeStr = _getTimeFromTransaction(transaction);
    
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 12,
          color: appColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          timeStr,
          style: TextStyle(
            fontFamily: 'RobotoSlab',
            fontSize: 12,
            color: appColors.textSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final groupedTransactions = _groupTransactionsByDate();
    final groupKeys = groupedTransactions.keys.toList()..sort((a, b) {
      if (a == 'Today') return -1;
      if (b == 'Today') return 1;
      if (a == 'Yesterday') return -1;
      if (b == 'Yesterday') return 1;
      return b.compareTo(a);
    });

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? null
            : const Text(
                'All Transactions',
                style: TextStyle(
                  fontFamily: 'RobotoSlab',
                  fontWeight: FontWeight.w600,
                ),
              ),
        backgroundColor: appColors.appBarColor,
        foregroundColor: Colors.white,
        actions: _showSearch
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _showSearch = true;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _searchFocusNode.requestFocus();
                    });
                  },
                  tooltip: 'Search',
                ),
                IconButton(
                  icon: Icon(
                    _showActions ? Icons.close : Icons.edit_note,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _showActions = !_showActions;
                      if (!_showActions) {
                        _selectedIndex = null;
                      }
                    });
                  },
                  tooltip: _showActions ? 'Hide Actions' : 'Show Actions',
                ),
              ],
      ),
      body: SafeArea(child: Column(
        children: [
          // Search Bar
          if (_showSearch) _buildSearchBar(),
          
          // Filters Section
          Container(
            color: appColors.lightGreyCard, 
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Type Filter
                Row(
                  children: [
                    const Text(
                      'Type:',
                      style: TextStyle(
                        fontFamily: 'RobotoSlab',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ...typeFilters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: FilterChip(
                          label: Text(
                            filter,
                            style: const TextStyle(fontFamily: 'RobotoSlab'),
                          ),
                          selected: _selectedTypeFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTypeFilter = filter;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Date Range Filter
                Row(
                  children: [
                    const Text(
                      'Date:',
                      style: TextStyle(
                        fontFamily: 'RobotoSlab',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectDateRange(context),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          _startDate != null && _endDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Select Date Range',
                          style: const TextStyle(fontFamily: 'RobotoSlab'),
                        ),
                      ),
                    ),
                    if (_startDate != null && _endDate != null) ...[
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: _clearDateFilter,
                        icon: const Icon(Icons.clear, size: 20),
                        tooltip: 'Clear date filter',
                      ),
                    ],
                  ],
                ),
                
                // Search info result
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.search, size: 16, color: appColors.textPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'Search results for "$_searchQuery": ${_filteredTransactions.length} transactions',
                        style: const TextStyle(
                          fontFamily: 'RobotoSlab',
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Transactions List
          Expanded(
            child: _filteredTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No transactions found for "$_searchQuery"'
                            : 'No transactions found',
                        style: TextStyle(
                          fontFamily: 'RobotoSlab',
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Try a different search term'
                            : 'Try changing your filters',
                        style: TextStyle(
                          fontFamily: 'RobotoSlab',
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: _clearSearch,
                          child: const Text(
                            'Clear Search',
                            style: TextStyle(fontFamily: 'RobotoSlab'),
                          ),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: groupKeys.length,
                  itemBuilder: (context, groupIndex) {
                    final header = groupKeys[groupIndex];
                    final transactions = groupedTransactions[header]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: appColors.filterChip,
                          child: Text(
                            header,
                            style: const TextStyle(
                              fontFamily: 'RobotoSlab',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        
                        // Transactions for this date
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            final globalIndex = _filteredTransactions.indexOf(transaction);
                            final isSelected = _selectedIndex == globalIndex;
                            
                            return GestureDetector(
                              onTap: _showActions
                                  ? () {
                                      setState(() {
                                        _selectedIndex = _selectedIndex == globalIndex ? null : globalIndex;
                                      });
                                    }
                                  : null,
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Icon income/expense
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: transaction['isIncome'] 
                                                  ? Color.fromRGBO(76, 175, 80, 0.1)
                                                  : Color.fromRGBO(76, 175, 80, 0.1),
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
                                          
                                          // Informasi transaksi
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // deskripsi
                                                Text(
                                                  transaction['description'],
                                                  style: const TextStyle(
                                                    fontFamily: 'RobotoSlab',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                
                                                // date
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    _buildFormattedDate(transaction['date']),
                                                      
                                                    const SizedBox(height: 4),
                                                    
                                                    // Category dan Time
                                                    Row(
                                                      children: [
                                                        // Category
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
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
                                                        const SizedBox(width: 12),
                                                        
                                                        // Waktu
                                                        _buildTimeDisplay(transaction),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          // Jumlah Transaksi
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              FutureBuilder<String>(
                                                future: _formatCurrency(
                                                  transaction['amount'], 
                                                  transaction['isIncome']
                                                ),
                                                builder: (context, snapshot) {
                                                  return Text(
                                                    snapshot.data ?? '',
                                                    style: TextStyle(
                                                      fontFamily: 'RobotoSlab',
                                                      fontWeight: FontWeight.w700,
                                                      color: transaction['isIncome'] 
                                                          ? Colors.green 
                                                          : Colors.red,
                                                      fontSize: 16,
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: transaction['isIncome'] 
                                                      ? Color.fromRGBO(76, 175, 80, 0.1)
                                                      : Color.fromRGBO(76, 175, 80, 0.1),
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
                                    
                                    // Action buttons (edit/delete)
                                    if (_showActions && isSelected)
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: appColors.lightBlueCard,
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                                onPressed: () => _editTransaction(transaction, globalIndex),
                                                tooltip: 'Edit',
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                                onPressed: () => _deleteTransaction(globalIndex),
                                                tooltip: 'Delete',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // EXTRA SPACE
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
          ),
        ],
      ),
      ),
    );
  }
}