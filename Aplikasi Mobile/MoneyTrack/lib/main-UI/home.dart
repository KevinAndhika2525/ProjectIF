import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'allTransaction.dart';
import '../helper/colors.dart';
import '../helper/currency_helper.dart';
import 'settings.dart';
import '../sub-UI/summary.dart';
import '../sub-UI/recent.dart';
import 'transaction.dart';
import '../helper/local_storage.dart';
import 'login.dart';
import '../helper/authService.dart';

class HomePage extends StatefulWidget {
  final String username;
  final int userId;
  final String token;

  const HomePage({
    super.key, 
    required this.username,
    required this.userId,
    required this.token,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

// Default Currency
String _currencySymbol = 'Rp';

class _HomePageState extends State<HomePage> {
  double _balance = 0.0;
  String _selectedFilter = 'All';
  List<String> filters = ['All', 'Weekly', 'Monthly', 'Yearly'];

  List<Map<String, dynamic>> _recentTransactions = [];
  double _totalIncome = 0.0;        // Income berdasarkan filter (untuk chart)
  double _totalExpense = 0.0;       // Expense berdasarkan filter (untuk chart)
  double _totalIncomeAllTime = 0.0; // INI BARU: Income keseluruhan (tanpa filter)
  double _totalExpenseAllTime = 0.0; // INI BARU: Expense keseluruhan (tanpa filter)
  bool _isSaving = false;
  bool _isInitialized = false;
  late String _username;

  @override
  void initState() {
    super.initState();
    
    _username = widget.username;
    
    _saveLastUsername();
    
    // Load data immediately
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeData();
    });
    
    // Save data when app goes to background
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        detachCallback: _saveData,
        resumeCallback: () {
          if (mounted) {
            _loadData();
            _loadCurrency();
          }
        },
      ),
    );
  }
  
  Future<void> _initializeData() async {
    await _loadCurrency();
    await _loadData();
    
    setState(() {
      _isInitialized = true;
    });
  }
  
  Future<void> _saveLastUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_username', _username);
    } catch (e) {
      print('✗ Error saving last username: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Memuat ulang currency ketika dependencies berubah
    _loadCurrency();
  }

  @override
  void dispose() {
    // Save data before disposing
    _saveData();
    super.dispose();
  }

  Future<void> _loadData() async {
    
    try {
      final savedBalance = await LocalStorage.getBalance();
      final savedTransactions = await LocalStorage.getTransactions();
      
      if (mounted) {
        setState(() {
          _balance = savedBalance;
          _recentTransactions = savedTransactions;
        });
      }

      _calculateSummary();
      
    } catch (e) {
      print('✗ ERROR LOADING DATA: $e');
    }
  }

  Future<void> _saveData() async {
    if (_isSaving) return;
    
    _isSaving = true;
    try {
      await LocalStorage.saveBalance(_balance);
      await LocalStorage.saveTransactions(_recentTransactions);
      
    } catch (e) {
      print('✗ Error saving data: $e');
    } finally {
      _isSaving = false;
    }
  }

  Future<void> _logout() async {
    // Tampilkan konfirmasi dialog SEDERHANA
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(
            fontFamily: 'RobotoSlab',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?\n\nYour transaction data will be saved for when you login again.',
          style: TextStyle(fontFamily: 'RobotoSlab'),
        ),
        actions: [
          // Button untuk cancel
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'RobotoSlab'),
            ),
          ),
          
          // Button untuk logout
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'RobotoSlab',
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    // Logout biasa - preserve data
    await _performLogout();
  }
  
  Future<void> _performLogout() async {
    await _saveData();
    await AuthService.logout();
    
    // Tampilkan notifikasi
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Logged out successfully.',
            style: TextStyle(fontFamily: 'RobotoSlab'),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    // Navigate to login page
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _addIncome() {
    _navigateToTransactionPage('Income');
  }

  void _addExpense() {
    _navigateToTransactionPage('Expense');
  }

  void _navigateToTransactionPage(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionPage(
          defaultType: type,
          onSave: (transaction) {
            // Tambahkan transaksi ke daftar
            _addTransaction(
              transaction['amount'],
              transaction['description'],
              transaction['isIncome'],
              transaction['date'],
              time: transaction['time'],
              category: transaction['category'],
            );
          },
        ),
      ),
    ).then((result) {
      if (result != null) {
        _calculateSummary();
        _saveData();
        setState(() {});
      }
    });
  }

  void _addTransaction(double amount, String description, bool isIncome, String date, 
                      {String time = '00:00', String category = 'Other'}) {
    
    setState(() {
      if (isIncome) {
        _balance += amount;
      } else {
        _balance -= amount;
      }

      final transaction = {
        'amount': amount,
        'description': description,
        'isIncome': isIncome,
        'date': date,
        'time': time,
        'category': category,
        'type': isIncome ? 'Income' : 'Expense',
        'dateTime': _parseDateWithTime(date, time),
      };
      
      _recentTransactions.insert(0, transaction);
    });
  }

  DateTime _parseDateWithTime(String dateString, String timeString) {
    try {
      final dateParts = dateString.split('/');
      if (dateParts.length == 3) {
        int hour = 0;
        int minute = 0;
        
        // Parse waktu
        if (timeString.contains(':')) {
          final timeParts = timeString.split(':');
          if (timeParts.length >= 2) {
            hour = int.tryParse(timeParts[0]) ?? 0;
            minute = int.tryParse(timeParts[1]) ?? 0;
          }
        }
        
        return DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
          hour,
          minute,
        );
      }
    } catch (e) {
      print('✗ Error parsing date with time: $e');
    }
    return DateTime.now();
  }

  void _calculateSummary() {
    final now = DateTime.now();
    double totalIncomeFiltered = 0.0;
    double totalExpenseFiltered = 0.0;
    double totalIncomeAllTime = 0.0; // Untuk income keseluruhan
    double totalExpenseAllTime = 0.0; // Untuk expense keseluruhan

    for (final transaction in _recentTransactions) {
      try {
        final transactionDate = transaction['dateTime'] as DateTime? ?? DateTime.now();
        final amount = transaction['amount'] as double? ?? 0.0;
        final isIncome = transaction['isIncome'] as bool? ?? false;

        // SELALU hitung income dan expense keseluruhan (untuk ditampilkan di atas pie chart)
        if (isIncome) {
          totalIncomeAllTime += amount;
        } else {
          totalExpenseAllTime += amount;
        }

        // Filter berdasarkan periode yang dipilih (untuk chart)
        bool includeTransaction = true;
        
        if (_selectedFilter == 'Weekly') {
          final weekAgo = now.subtract(const Duration(days: 7));
          includeTransaction = transactionDate.isAfter(weekAgo);
        } else if (_selectedFilter == 'Monthly') {
          final monthAgo = DateTime(now.year, now.month - 1, now.day);
          includeTransaction = transactionDate.isAfter(monthAgo);
        } else if (_selectedFilter == 'Yearly') {
          final yearAgo = DateTime(now.year - 1, now.month, now.day);
          includeTransaction = transactionDate.isAfter(yearAgo);
        }

        if (includeTransaction) {
          if (isIncome) {
            totalIncomeFiltered += amount;
          } else {
            totalExpenseFiltered += amount;
          }
        }
      } catch (e) {
        print('✗ Error calculating transaction: $e');
      }
    }

    if (mounted) {
      setState(() {
        _totalIncome = totalIncomeFiltered;
        _totalExpense = totalExpenseFiltered;
        _totalIncomeAllTime = totalIncomeAllTime; // Simpan income keseluruhan
        _totalExpenseAllTime = totalExpenseAllTime; // Simpan expense keseluruhan
      });
    }
  }

  // PERBAIKAN: Fungsi update transaksi YANG BENAR
  void _updateTransactionDirectly(int index, Map<String, dynamic> updatedTransaction) {
    setState(() {
      final oldTransaction = _recentTransactions[index];
      final oldAmount = oldTransaction['amount'] as double;
      final oldIsIncome = oldTransaction['isIncome'] as bool;
      
      final newAmount = updatedTransaction['amount'] as double;
      final newIsIncome = updatedTransaction['isIncome'] as bool;
      final newTime = updatedTransaction['time'] as String? ?? '00:00';
      
      // Update balance: batalkan yang lama, tambah yang baru
      if (oldIsIncome) {
        _balance -= oldAmount; // Batalkan income lama
      } else {
        _balance += oldAmount; // Batalkan expense lama
      }
      
      if (newIsIncome) {
        _balance += newAmount; // Tambah income baru
      } else {
        _balance -= newAmount; // Tambah expense baru
      }
      
      // PERBAIKAN PENTING: Ganti transaksi di posisi index yang sama
      _recentTransactions[index] = {
        'amount': newAmount,
        'description': updatedTransaction['description'] ?? '',
        'isIncome': newIsIncome,
        'date': updatedTransaction['date'] ?? '',
        'time': newTime,
        'category': updatedTransaction['category'] ?? 'Other',
        'type': newIsIncome ? 'Income' : 'Expense',
        'dateTime': updatedTransaction['dateTime'] ?? DateTime.now(),
      };
      
      // Recalculate summary
      _calculateSummary();
      // Save data
      _saveData();
    });
  }

  void _deleteTransaction(int index) {
    setState(() {
      final transaction = _recentTransactions[index];
      final amount = transaction['amount'] as double;
      final isIncome = transaction['isIncome'] as bool;
      
      // Update balance
      if (isIncome) {
        _balance -= amount;
      } else {
        _balance += amount;
      }
      
      // Remove transaction
      _recentTransactions.removeAt(index);
      
      // Recalculate summary
      _calculateSummary();
      // Save data
      _saveData();
    });
  }

  Future<void> _loadCurrency() async {
    try {
      final symbol = await CurrencyHelper.getCurrencySymbol();
      if (mounted) {
        setState(() {
          _currencySymbol = symbol;
        });
      }
    } catch (e) {
      print('✗ Error loading currency: $e');
    }
  }

  String _formatSimpleCurrency(double amount) {
    return '$_currencySymbol ${amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )
    }';
  }

  // PERBAIKAN BESAR: Fungsi showAllTransactions dengan mekanisme yang benar
  void _showAllTransactions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllTransactionsPage(
          transactions: _recentTransactions,
          onUpdate: (index, updatedTransaction) {
            // PERBAIKAN: index sudah dihitung dengan benar di AllTransactionsPage
            if (index >= 0 && index < _recentTransactions.length) {
              // Langsung update transaksi di index tersebut
              _updateTransactionDirectly(index, updatedTransaction);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Transaction updated successfully',
                    style: TextStyle(fontFamily: 'RobotoSlab'),
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              print('✗ Invalid index for update: $index');
            }
          },
          onDelete: (index) {
            if (index >= 0 && index < _recentTransactions.length) {
              _deleteTransaction(index);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Transaction deleted successfully',
                    style: TextStyle(fontFamily: 'RobotoSlab'),
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              print('✗ Invalid index for deletion: $index');
            }
          },
        ),
      ),
    ).then((_) {
      // Refresh data when returning from all transactions page
      _calculateSummary();
      _saveData();
      _loadCurrency();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('MoneyTrack'),
          backgroundColor: appColors.appBarColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Loading your data...',
                style: TextStyle(
                  fontFamily: 'RobotoSlab',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyTrack'),
        backgroundColor: appColors.appBarColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              
              // Save data sebelum ke Settings
              await _saveData();
              
              // Navigate to Settings
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              
              // Tunggu sedikit untuk memastikan context ready
              await Future.delayed(const Duration(milliseconds: 300));
              
              if (mounted) {
                await _loadCurrency();
                await _loadData();
                setState(() {});
              }
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan user info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle, size: 40, color: Colors.blue),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $_username',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'RobotoSlab',
                          ),
                        ),
                        Text(
                          'Welcome to MoneyTrack',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'RobotoSlab',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Balance Card dengan tombol Add Income/Expense di samping
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                Expanded(
                  child: _buildBalanceCard(context, appColors),
                ),
                const SizedBox(width: 10),
                
                // Tombol Add Income/Expense
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addIncome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        textStyle: const TextStyle(
                          fontFamily: 'RobotoSlab',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add\nIncome', textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 7),
                    ElevatedButton.icon(
                      onPressed: _addExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: const Icon(Icons.remove, size: 20),
                      label: const Text('Add\nExpense', textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Summary Section (Menggunakan SummaryPage)
            SummaryPage(
              totalIncome: _totalIncome,           // Income berdasarkan filter (untuk chart)
              totalIncomeAllTime: _totalIncomeAllTime, // INI BARU: Income keseluruhan
              totalExpense: _totalExpense,         // Expense berdasarkan filter (untuk chart)
              totalExpenseAllTime: _totalExpenseAllTime, // INI BARU: Expense keseluruhan
              selectedFilter: _selectedFilter,
              filters: filters,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                  _calculateSummary();
                });
              },
              currencySymbol: _currencySymbol,
            ),
            const SizedBox(height: 30),

            // Recent Transactions Section (Menggunakan RecentTransactions)
            RecentTransactions(
              transactions: _recentTransactions,
              currencySymbol: _currencySymbol,
              onViewAll: _showAllTransactions,
            ),
            
            // EXTRA SPACE
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk mendeteksi apakah teks akan overflow
  bool _willTextOverflow(String text, TextStyle style, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  // Fungsi untuk mendapatkan ukuran font yang optimal
  double _getOptimalFontSize(
    double balance, 
    BuildContext context, 
    double maxWidth,
    AppColors appColors
  ) {
    final balanceText = _formatSimpleCurrency(balance);
    
    // Daftar ukuran font untuk dicoba (dari besar ke kecil)
    final fontSizes = [32.0, 30.0, 28.0, 26.0, 24.0, 22.0, 20.0, 18.0, 16.0];
    
    for (final fontSize in fontSizes) {
      final style = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'RobotoSlab',
        color: appColors.textPrimary,
      );
      
      // Cek jika teks tidak overflow dengan ukuran font ini
      if (!_willTextOverflow(balanceText, style, maxWidth)) {
        return fontSize;
      }
    }
    
    // Jika semua ukuran font menyebabkan overflow, gunakan ukuran minimum
    return 16.0;
  }

  // Widget untuk menampilkan balance dengan ukuran font responsif
  Widget _buildBalanceCard(BuildContext context, AppColors appColors) {
    return Card(
      elevation: 4,
      color: appColors.balanceCard,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Balance',
              style: TextStyle(
                fontSize: 16,
                color: appColors.textSecondary,
                fontFamily: 'RobotoSlab',
              ),
            ),
            const SizedBox(height: 10),
            
            // Container 
            SizedBox(
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final optimalFontSize = _getOptimalFontSize(
                    _balance, 
                    context, 
                    maxWidth,
                    appColors
                  );
                  
                  return Center(
                    child: Text(
                      _formatSimpleCurrency(_balance),
                      style: TextStyle(
                        fontSize: optimalFontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RobotoSlab',
                        color: appColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
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

// Helper class untuk handle app lifecycle
class LifecycleEventHandler extends WidgetsBindingObserver {
  final VoidCallback detachCallback;
  final VoidCallback resumeCallback;

  LifecycleEventHandler({
    required this.detachCallback,
    required this.resumeCallback,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        detachCallback();
        break;
      case AppLifecycleState.resumed:
        resumeCallback();
        break;
      case AppLifecycleState.inactive:
        // App is inactive but still visible
        break;
      case AppLifecycleState.hidden:
        // Android-specific state
        detachCallback();
        break;
    }
  }
}