import 'package:flutter/material.dart';
import '../helper/colors.dart';
import '../helper/currency_helper.dart';
import '../helper/formatter.dart'; 
import '../helper/local_storage.dart'; 

class TransactionPage extends StatefulWidget {
  final String? defaultType;
  final Function(Map<String, dynamic>)? onSave;
  final Map<String, dynamic>? transactionToEdit;
  final List<String>? categories; 

  const TransactionPage({
    super.key,
    this.defaultType,
    this.onSave,
    this.transactionToEdit,
    this.categories,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String _currencySymbol = 'Rp';
  String _selectedType = 'Income';
  String _selectedCategory = 'Groceries';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _dateFormatHint = 'DD/MM/YYYY';
  List<String> _availableCategories = [];
  List<Map<String, dynamic>> _categoryData = [];

  @override
  void initState() {
    super.initState();
    _loadCurrency();
    _loadDateFormatHint();
    _loadCategories();
    
    // Jika ada transaksi untuk diedit, load datanya
    if (widget.transactionToEdit != null) {
      final transaction = widget.transactionToEdit!;
      _selectedType = transaction['isIncome'] ? 'Income' : 'Expense';
      _amountController.text = (transaction['amount'] as double).toString();
      _selectedCategory = transaction['category'] ?? 'Groceries';
      _descriptionController.text = transaction['description'] ?? '';
      
      try {
        // Formatter tanggal awal
        final dateTime = transaction['dateTime'] as DateTime? ?? DateTime.now();
        _selectedDate = dateTime;
        _loadFormattedDate(dateTime);
        
        // Parse time
        _selectedTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      } catch (e) {
        _selectedDate = DateTime.now();
        _loadFormattedDate(_selectedDate);
        _selectedTime = TimeOfDay.now();
      }
      _timeController.text = _formatTime(_selectedTime);
    } else {
      if (widget.defaultType != null) {
        _selectedType = widget.defaultType!;
      }
      
      _selectedDate = DateTime.now();
      _loadFormattedDate(_selectedDate);
      _selectedTime = TimeOfDay.now();
      _timeController.text = _formatTime(_selectedTime);
    }
  }

  Future<void> _loadCurrency() async {
    final symbol = await CurrencyHelper.getCurrencySymbol();
    if (mounted) {
      setState(() {
        _currencySymbol = symbol;
      });
    }
  }
  
  Future<void> _loadDateFormatHint() async {
    final format = await LocalStorage.getDateFormat() ?? 'DD/MM/YYYY';
    if (mounted) {
      setState(() {
        _dateFormatHint = _getFormatExample(format);
      });
    }
  }
  
  Future<void> _loadCategories() async {
    final categories = await LocalStorage.getCategories();
    final categoryNames = await LocalStorage.getCategoryNames();
    
    if (mounted) {
      setState(() {
        _availableCategories = categoryNames;
        _categoryData = categories;
        
        // default category
        if (!_availableCategories.contains(_selectedCategory) && _availableCategories.isNotEmpty) {
          _selectedCategory = _availableCategories[0];
        }
      });
    }
  }
  
  String _getFormatExample(String format) {
    switch (format) {
      case 'DD/MM/YYYY': return 'DD/MM/YYYY';
      case 'DD/MMM/YYYY': return 'DD/MMM/YYYY';
      case 'DD-MM-YYYY': return 'DD-MM-YYYY';
      case 'DD-MMM-YYYY': return 'DD-MMM-YYYY';
      case 'D Month, YYYY': return 'D Month, YYYY';
      default: return 'DD/MM/YYYY';
    }
  }
  Future<void> _loadFormattedDate(DateTime date) async {
    final formattedDate = await Formatter.formatDate(date);
    if (mounted) {
      setState(() {
        _dateController.text = formattedDate;
      });
    }
  }

  // format waktu
  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // format tanggal
  String _formatDateForStorage(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadFormattedDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = _formatTime(picked);
      });
    }
  }

  void _saveTransaction() {
    final amountText = _amountController.text.trim();
    
    if (amountText.isEmpty) {
      _showError('Please enter amount');
      return;
    }
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Please enter valid amount');
      return;
    }
    
    // Combine date and time
    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    
    final transaction = {
      'amount': amount,
      'description': _descriptionController.text.trim(),
      'isIncome': _selectedType == 'Income',
      'category': _selectedCategory,
      'date': _formatDateForStorage(combinedDateTime),
      'time': _timeController.text,
      'type': _selectedType,
      'dateTime': combinedDateTime,
    };
    // Jika sedang diedit
    if (widget.transactionToEdit != null) {
      if (widget.transactionToEdit!.containsKey('dateTime')) {
        transaction['originalDateTime'] = widget.transactionToEdit!['dateTime'];
      }
      transaction['originalDate'] = widget.transactionToEdit!['date'];
      transaction['originalTime'] = widget.transactionToEdit!['time'];
      transaction['originalAmount'] = widget.transactionToEdit!['amount'];
      transaction['originalDescription'] = widget.transactionToEdit!['description'];
    }
    widget.onSave?.call(transaction);
    Navigator.pop(context, transaction);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final isIncome = _selectedType == 'Income';
    final amountColor = isIncome ? Colors.green : Colors.red;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionToEdit != null ? 'Edit Transaction' : 'Add Transaction'),
        backgroundColor: appColors.appBarColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Income/Expense
            const Text(
              'Transaction Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoSlab',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                  // income
                Expanded(
                  child: ChoiceChip(
                    label: Text(
                      'Income',
                      style: TextStyle(
                        color: appColors.textPrimary,
                        fontFamily: 'RobotoSlab',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: _selectedType == 'Income',
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = 'Income';
                      });
                    },
                    backgroundColor: appColors.lightGreyCard,
                    selectedColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                  // expense
                Expanded(
                  child: ChoiceChip(
                    label: const Text(
                      'Expense',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'RobotoSlab',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: _selectedType == 'Expense',
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = 'Expense';
                      });
                    },
                    backgroundColor: appColors.lightGreyCard,
                    selectedColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Amount
            const Text(
              'Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoSlab',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE3F2FD)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: appColors.lightGreyCard,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      _currencySymbol,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RobotoSlab',
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontFamily: 'RobotoSlab',
                          color: Colors.grey,
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'RobotoSlab',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Category Dropdown
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoSlab',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE3F2FD)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: _availableCategories.map((String category) {
                    // warna dan icon kategori 
                    final categoryInfo = _categoryData.firstWhere(
                      (cat) => cat['name'] == category,
                      orElse: () => {'color': Colors.blue, 'icon': Icons.category},
                    );
                    
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: categoryInfo['color'].withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              categoryInfo['icon'],
                              color: categoryInfo['color'],
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            category,
                            style: const TextStyle(fontFamily: 'RobotoSlab'),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Date Picker
            const Text(
              'Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoSlab',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
                hintText: _dateFormatHint,
                hintStyle: const TextStyle(
                  fontFamily: 'RobotoSlab',
                  color: Colors.grey,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'RobotoSlab',
              ),
            ),
            const SizedBox(height: 20),
            
            // Time Picker
            const Text(
              'Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoSlab',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _timeController,
              readOnly: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _selectTime(context),
                ),
                hintText: 'HH:MM (24-hour format)',
                hintStyle: const TextStyle(
                  fontFamily: 'RobotoSlab',
                  color: Colors.grey,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'RobotoSlab',
              ),
            ),
            const SizedBox(height: 20),
            
            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoSlab',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
                hintText: 'Add description...',
                hintStyle: TextStyle(
                  fontFamily: 'RobotoSlab',
                  color: Colors.grey,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'RobotoSlab',
              ),
            ),
            const SizedBox(height: 40),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.transactionToEdit != null ? 'Update Transaction' : 'Save Transaction',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'RobotoSlab',
                  ),
                ),
              ),
            ),
            // EXTRA SPACE
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}