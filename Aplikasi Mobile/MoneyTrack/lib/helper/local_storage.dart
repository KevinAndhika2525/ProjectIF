import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authService.dart';
import 'user_storage.dart' as user_storage;

class LocalStorage {
  static const String _usernameKey = 'username';
  static const String _transactionsKey = 'transactions';
  static const String _balanceKey = 'balance';
  static const String _currencyKey = 'currency';
  static const String _dateFormatKey = 'date_format';
  static const String _categoriesKey = 'categories';
  static const String _themeModeKey = 'theme_mode';

  // ==================== USERNAME METHODS ====================
  
  // Simpan username
  static Future<void> saveUsername(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);
    } catch (e) {
      print('✗ Error saving username: $e');
      rethrow;
    }
  }

  // Ambil username
  static Future<String?> getUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString(_usernameKey);
      return username;
    } catch (e) {
      print('✗ Error loading username: $e');
      return null;
    }
  }

  // ==================== TRANSACTIONS METHODS ====================

  // Simpan transaksi dengan proper JSON serialization
  static Future<void> saveTransactions(List<Map<String, dynamic>> transactions) async {
    try {
      await user_storage.UserStorage.saveTransactions(transactions);
    } catch (e) {
      print('✗ Error saving transactions: $e');
      rethrow;
    }
  }
  
  // Ambil transaksi dengan proper JSON deserialization
  static Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      return await user_storage.UserStorage.getTransactions();
    } catch (e) {
      print('✗ Error loading transactions: $e');
      return [];
    }
  }
  // ==================== BALANCE METHODS ====================

  // Simpan balance
  static Future<void> saveBalance(double balance) async {
    try {
      await user_storage.UserStorage.saveBalance(balance);
    } catch (e) {
      print('✗ Error saving balance: $e');
      rethrow;
    }
  }

  // Ambil balance
  static Future<double> getBalance() async {
    try {
      return await user_storage.UserStorage.getBalance();
    } catch (e) {
      print('✗ Error loading balance: $e');
      return 0.0;
    }
  }

  // ==================== CLEAR METHODS ====================

  // Clear user session data only (keep transactions and balance)
  static Future<void> clearUserData() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      
      if (isLoggedIn) {
        await AuthService.logout();
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_usernameKey);
      }
    } catch (e) {
      print('✗ Error clearing user data: $e');
      rethrow;
    }
  }

  // Clear ALL data including transactions and balance
  // Hanya gunakan ini jika user ingin reset total
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Hapus semua data user
      await prefs.remove(_usernameKey);
      await prefs.remove(_transactionsKey);
      await prefs.remove(_balanceKey);
      await prefs.remove(_categoriesKey);
      await prefs.remove(_currencyKey);
      await prefs.remove(_dateFormatKey);
      await prefs.remove(_themeModeKey);
      
      // Jika menggunakan sistem multi-user, hapus juga user-specific keys
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.contains('transactions_') || 
            key.contains('balance_') || 
            key.contains('categories_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('✗ Error clearing all data: $e');
      rethrow;
    }
  }

  // ==================== UTILITY METHODS ====================

  // Get all stored keys (for debugging)
  static Future<List<String>> getAllKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getKeys().toList();
    } catch (e) {
      print('✗ Error getting all keys: $e');
      return [];
    }
  }

  // Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    try {
      final username = await getUsername();
      return username != null && username.isNotEmpty;
    } catch (e) {
      print('✗ Error checking login status: $e');
      return false;
    }
  }

  // Get total transaction count
  static Future<int> getTransactionCount() async {
    try {
      final transactions = await getTransactions();
      return transactions.length;
    } catch (e) {
      print('✗ Error getting transaction count: $e');
      return 0;
    }
  }

  // ==================== MIGRATION METHODS ====================

  // Migrate old transaction format to new format with dateTime
  static Future<void> migrateTransactions() async {
    try {
      final transactions = await getTransactions();
      bool needsMigration = false;
      
      for (final transaction in transactions) {
        if (!transaction.containsKey('dateTime') || !transaction.containsKey('time')) {
          needsMigration = true;
          break;
        }
      }
      
      if (needsMigration) {
        final migratedTransactions = <Map<String, dynamic>>[];
        
        for (final transaction in transactions) {
          final migrated = Map<String, dynamic>.from(transaction);
          
          if (!migrated.containsKey('dateTime')) {
            // Coba buat dateTime dari date field
            if (migrated.containsKey('date') && migrated['date'] is String) {
              try {
                final dateStr = migrated['date'] as String;
                final parts = dateStr.split('/');
                if (parts.length == 3) {
                  // Gunakan waktu dari field 'time' jika ada, atau default 12:00
                  int hour = 12;
                  int minute = 0;
                  
                  if (migrated.containsKey('time') && migrated['time'] is String) {
                    final timeStr = migrated['time'] as String;
                    final timeParts = timeStr.split(':');
                    if (timeParts.length == 2) {
                      hour = int.tryParse(timeParts[0]) ?? 12;
                      minute = int.tryParse(timeParts[1]) ?? 0;
                    }
                  }
                  
                  migrated['dateTime'] = DateTime(
                    int.parse(parts[2]),
                    int.parse(parts[1]),
                    int.parse(parts[0]),
                    hour,
                    minute,
                  );
                }
              } catch (e) {
                migrated['dateTime'] = DateTime.now();
              }
            } else {
              migrated['dateTime'] = DateTime.now();
            }
          }
          
          // Pastikan field 'time' ada
          if (!migrated.containsKey('time') || migrated['time'] == null) {
            if (migrated.containsKey('dateTime') && migrated['dateTime'] is DateTime) {
              final dateTime = migrated['dateTime'] as DateTime;
              migrated['time'] = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
            } else {
              migrated['time'] = '12:00';
            }
          }
          
          migratedTransactions.add(migrated);
        }
        
        await saveTransactions(migratedTransactions);
      }
    } catch (e) {
      print('✗ Error during migration: $e');
    }
  }

  // ==================== DEBUG METHODS ====================
  // Add sample data for testing
  static Future<void> addSampleData() async {
    try {
      final sampleTransactions = [
        {
          'amount': 1000000.0,
          'description': 'Monthly Salary',
          'isIncome': true,
          'category': 'Salary',
          'date': '01/12/2024',
          'time': '09:00',
          'type': 'Income',
          'dateTime': DateTime(2024, 12, 1, 9, 0),
        },
        {
          'amount': 500000.0,
          'description': 'Freelance Project',
          'isIncome': true,
          'category': 'Freelance',
          'date': '05/12/2024',
          'time': '14:30',
          'type': 'Income',
          'dateTime': DateTime(2024, 12, 5, 14, 30),
        },
        {
          'amount': 250000.0,
          'description': 'Grocery Shopping',
          'isIncome': false,
          'category': 'Groceries',
          'date': '10/12/2024',
          'time': '16:45',
          'type': 'Expense',
          'dateTime': DateTime(2024, 12, 10, 16, 45),
        },
        {
          'amount': 150000.0,
          'description': 'Electricity Bill',
          'isIncome': false,
          'category': 'Utilities',
          'date': '15/12/2024',
          'time': '12:00',
          'type': 'Expense',
          'dateTime': DateTime(2024, 12, 15, 12, 0),
        },
        {
          'amount': 300000.0,
          'description': 'Dinner at Restaurant',
          'isIncome': false,
          'category': 'Food',
          'date': '20/12/2024',
          'time': '19:30',
          'type': 'Expense',
          'dateTime': DateTime(2024, 12, 20, 19, 30),
        },
      ];
      
      await saveUsername('test_user');
      await saveBalance(1250000.0);
      await saveTransactions(sampleTransactions);
      
      print('✅ Sample data added successfully');
      print('  Username: test_user');
      print('  Balance: 1,250,000');
      print('  Transactions: 5 sample transactions');
      
    } catch (e) {
      print('✗ Error adding sample data: $e');
    }
  }

  // ==================== CURRENCY METHODS ====================
  static Future<void> saveCurrency(String currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, currency);
    } catch (e) {
      print('✗ Error saving currency: $e');
      rethrow;
    }
  }

  static Future<String?> getCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_currencyKey);
    } catch (e) {
      print('✗ Error loading currency: $e');
      return null;
    }
  }

  // ==================== DATE FORMAT METHODS ====================
  static Future<void> saveDateFormat(String format) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dateFormatKey, format);
    } catch (e) {
      print('✗ Error saving date format: $e');
      rethrow;
    }
  }

  static Future<String?> getDateFormat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_dateFormatKey);
    } catch (e) {
      print('✗ Error loading date format: $e');
      return null;
    }
  }

  // ==================== CATEGORIES METHODS ====================
  
  static Future<void> saveCategories(List<Map<String, dynamic>> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert categories to JSON-serializable list
      final List<Map<String, dynamic>> serializableCategories = categories.map((category) {
        final iconData = category['icon'] as IconData;
        
        final Map<String, dynamic> serialized = {
          'id': category['id'],
          'name': category['name'],
          'iconCodePoint': iconData.codePoint,
          'iconFontFamily': iconData.fontFamily,
          'iconFontPackage': iconData.fontPackage,
          'color': (category['color'] as Color).value,
        };
        return serialized;
      }).toList();
      
      final String jsonString = jsonEncode(serializableCategories);
      await prefs.setString(_categoriesKey, jsonString);
    } catch (e) {
      print('✗ Error saving categories: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_categoriesKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return _getDefaultCategories();
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<Map<String, dynamic>> categories = [];
      
      for (final json in jsonList) {
        try {
          final Map<String, dynamic> category = Map<String, dynamic>.from(json);
          
          // Convert back to IconData
          final codePoint = category['iconCodePoint'] as int;
          final fontFamily = category['iconFontFamily'] as String?;
          final fontPackage = category['iconFontPackage'] as String?;
          
          category['icon'] = IconData(
            codePoint,
            fontFamily: fontFamily,
            fontPackage: fontPackage,
          );
          
          // Convert int back to Color
          final colorValue = category['color'] as int;
          category['color'] = Color(colorValue);
          
          // Remove serialized fields
          category.remove('iconCodePoint');
          category.remove('iconFontFamily');
          category.remove('iconFontPackage');
          
          categories.add(category);
          
        } catch (e) {
          print('✗ Skipping category due to error: $e');
          continue;
        }
      }
      return categories;
      
    } catch (e) {
      print('✗ Error loading categories: $e');
      return _getDefaultCategories();
    }
  }

  // Helper method to get default categories
  static List<Map<String, dynamic>> _getDefaultCategories() {
    return [
      {
        'id': 1,
        'name': 'Groceries',
        'icon': Icons.shopping_cart,
        'color': Colors.green,
      },
      {
        'id': 2,
        'name': 'Transportation',
        'icon': Icons.directions_bus,
        'color': Colors.blue,
      },
      {
        'id': 3,
        'name': 'Paying Bill',
        'icon': Icons.receipt_long,
        'color': Colors.orange,
      },
      {
        'id': 4,
        'name': 'Buying Food',
        'icon': Icons.restaurant,
        'color': Colors.red,
      },
      {
        'id': 5,
        'name': 'Salary',
        'icon': Icons.work,
        'color': Colors.green,
      },
      {
        'id': 6,
        'name': 'Entertainment',
        'icon': Icons.movie,
        'color': Colors.purple,
      },
      {
        'id': 7,
        'name': 'Healthcare',
        'icon': Icons.local_hospital,
        'color': Colors.red,
      },
      {
        'id': 8,
        'name': 'Education',
        'icon': Icons.school,
        'color': Colors.blue,
      },
      {
        'id': 9,
        'name': 'Travel',
        'icon': Icons.flight,
        'color': Colors.teal,
      },
      {
        'id': 10,
        'name': 'Gift',
        'icon': Icons.card_giftcard,
        'color': Colors.pink,
      },
      {
        'id': 11,
        'name': 'Other',
        'icon': Icons.more_horiz,
        'color': Colors.grey,
      },
    ];
  }

  // Add new category
  static Future<void> addCategory(Map<String, dynamic> category) async {
    final categories = await getCategories();
    
    // Generate new ID
    int newId = 1;
    if (categories.isNotEmpty) {
      final maxId = categories.map((c) => c['id'] as int).reduce((a, b) => a > b ? a : b);
      newId = maxId + 1;
    }
    
    final newCategory = {
      'id': newId,
      'name': category['name'],
      'icon': category['icon'],
      'color': category['color'],
    };
    
    categories.add(newCategory);
    await saveCategories(categories);
  }

  // Update existing category
  static Future<void> updateCategory(int id, Map<String, dynamic> updatedCategory) async {
    final categories = await getCategories();
    final index = categories.indexWhere((category) => category['id'] == id);
    
    if (index != -1) {
      categories[index] = {
        'id': id,
        'name': updatedCategory['name'],
        'icon': updatedCategory['icon'],
        'color': updatedCategory['color'],
      };
      await saveCategories(categories);
    }
  }

  // Delete category
  static Future<void> deleteCategory(int id) async {
    final categories = await getCategories();
    categories.removeWhere((category) => category['id'] == id);
    await saveCategories(categories);
  }

  // Get category names list for dropdown (sorted alphabetically)
  static Future<List<String>> getCategoryNames() async {
    final categories = await getCategories();
    final names = categories.map((category) => category['name'] as String).toList();
    names.sort(); // Sort alphabetically
    return names;
  }

  // Get first category name (for default selection)
  static Future<String> getFirstCategoryName() async {
    final categories = await getCategories();
    if (categories.isEmpty) {
      return 'Other';
    }
    final names = categories.map((category) => category['name'] as String).toList();
    names.sort(); // Sort alphabetically
    return names.first;
  }

  // Get all categories with icon and color
  static Future<List<Map<String, dynamic>>> getCategoriesWithDetails() async {
    return await getCategories();
  }

  // Clear all categories (for debugging)
  static Future<void> clearCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_categoriesKey);
  }

  // ==================== THEME METHODS ====================
  
  static Future<void> saveThemeMode(String themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, themeMode);
    } catch (e) {
      print('✗ Error saving theme mode: $e');
      rethrow;
    }
  }

  static Future<String> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_themeModeKey) ?? 'light';
    } catch (e) {
      print('✗ Error loading theme mode: $e');
      return 'light';
    }
  }

  static Future<ThemeMode> getThemeModeAsEnum() async {
    final themeMode = await getThemeMode();
    switch (themeMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }
}