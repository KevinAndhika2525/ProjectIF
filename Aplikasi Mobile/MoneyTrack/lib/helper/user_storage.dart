import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'authService.dart';

class UserStorage {
  // Generate user-specific key berdasarkan username yang TETAP ADA meski logout
  static Future<String> _getUserKey(String baseKey) async {
    // Gunakan helper dari AuthService yang sudah handle priority
    final storageUsername = await AuthService.getStorageUsername();
    
    if (storageUsername != null && storageUsername.isNotEmpty) {
      final key = '${baseKey}_$storageUsername';
      return key;
    }
    
    // Fallback ke user ID
    final userId = await AuthService.getUserId();
    if (userId != null) {
      final key = '${baseKey}_$userId';
      return key;
    }
    
    // Final fallback untuk debugging
    return '${baseKey}_default';
  }

  // Save transactions for current user
  static Future<void> saveTransactions(List<Map<String, dynamic>> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = await _getUserKey('transactions');
      final List<Map<String, dynamic>> serializableTransactions = transactions.map((transaction) {
        final Map<String, dynamic> serialized = Map.from(transaction);
        
        if (transaction.containsKey('dateTime') && transaction['dateTime'] is DateTime) {
          serialized['dateTime'] = (transaction['dateTime'] as DateTime).toIso8601String();
        }
        
        return serialized;
      }).toList();
      
      final String jsonString = jsonEncode(serializableTransactions);
      await prefs.setString(userKey, jsonString);
    } catch (e) {
      rethrow;
    }
  }

  // Get transactions for current user - FIXED VERSION
  static Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = await _getUserKey('transactions');
      final String? jsonString = prefs.getString(userKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<Map<String, dynamic>> transactions = [];
      
      for (final json in jsonList) {
        try {
          final Map<String, dynamic> transaction = Map<String, dynamic>.from(json);
          
          // Parse DateTime jika ada sebagai string
          if (transaction.containsKey('dateTime') && transaction['dateTime'] is String) {
            try {
              transaction['dateTime'] = DateTime.parse(transaction['dateTime'] as String);
            } catch (e) {
              transaction['dateTime'] = DateTime.now();
            }
          }
          
          transactions.add(transaction);
        } catch (e) {
          print('✗ Skipping invalid transaction: $e');
          continue;
        }
      }
      return transactions;
    } catch (e) {
      print('✗ Error loading transactions: $e');
      return [];
    }
  }

  // Save balance for current user
  static Future<void> saveBalance(double balance) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = await _getUserKey('balance');
      
      await prefs.setDouble(userKey, balance);
    } catch (e) {
      print('✗ Error saving balance: $e');
      rethrow;
    }
  }

  // Get balance for current user
  static Future<double> getBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = await _getUserKey('balance');
      final balance = prefs.getDouble(userKey) ?? 0.0;
      return balance;
    } catch (e) {
      print('✗ Error loading balance: $e');
      return 0.0;
    }
  }
  
  // Clear ALL data for current user (hanya untuk debugging)
  static Future<void> clearAllUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageUsername = await AuthService.getStorageUsername();
      final allKeys = prefs.getKeys();
      
      for (final key in allKeys) {
        if (storageUsername != null && key.contains('_$storageUsername')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('✗ Error clearing user data: $e');
      rethrow;
    }
  }
}