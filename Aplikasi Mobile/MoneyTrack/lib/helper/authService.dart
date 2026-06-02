import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'https://dummyjson.com';
  static const String _loginEndpoint = '/auth/login';
  
  // Simpan data user yang sedang login
  static Future<void> saveUserData({
    required String username,
    required String token,
    required int userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Simpan dengan dua key untuk redundancy
      await prefs.setString('auth_username', username);
      await prefs.setString('auth_token', token);
      await prefs.setInt('auth_user_id', userId);
      
      // Simpan username di key terpisah untuk data persistence (TIDAK AKAN DIHAPUS SAAT LOGOUT)
      await prefs.setString('last_username', username);
    } catch (e) {
      print('✗ Error saving user data: $e');
      rethrow;
    }
  }
  
  // Ambil token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('✗ Error getting token: $e');
      return null;
    }
  }
  
  // Ambil user ID
  static Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('auth_user_id');
    } catch (e) {
      print('✗ Error getting user ID: $e');
      return null;
    }
  }
  
  // Helper method untuk mendapatkan user ID dengan fallback
  static Future<int?> getUserIdWithFallback() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('auth_user_id');
      
      if (userId == null || userId == 0) {
        return null;
      }
      
      return userId;
    } catch (e) {
      print('✗ Error getting user ID: $e');
      return null;
    }
  }
  
  // Ambil username dari auth (hanya saat user logged in)
  static Future<String?> getAuthUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_username');
    } catch (e) {
      print('✗ Error getting auth username: $e');
      return null;
    }
  }
  
  // Ambil last username (selalu ada meski user logout)
  static Future<String?> getLastUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('last_username');
      return username;
    } catch (e) {
      print('✗ Error getting last username: $e');
      return null;
    }
  }
  
  // Login dengan API DummyJSON
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_loginEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Simpan data user
        await saveUserData(
          username: data['username'] ?? username,
          token: data['accessToken'],
          userId: data['id'] ?? 0,
        );
        
        return {
          'success': true,
          'message': 'Login successful',
          'user': {
            'username': data['username'],
            'id': data['id'],
            'token': data['accessToken'],
          }
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('✗ Login error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
  
  // Logout - HANYA hapus data autentikasi, TIDAK hapus data transaksi
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Hanya hapus data autentikasi
      await prefs.remove('auth_username');
      await prefs.remove('auth_token');
      await prefs.remove('auth_user_id');

    } catch (e) {
      print('✗ Logout error: $e');
      rethrow;
    }
  }
  
  // Clear ALL data termasuk transaksi (hanya untuk debugging atau reset)
  static Future<void> clearAllUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUsername = await getLastUsername();
      
      if (lastUsername != null) {
        // Hapus semua data dengan prefix last_username
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.contains('_$lastUsername')) {
            await prefs.remove(key);
          }
        }
      }
      
      // Hapus semua data autentikasi termasuk last_username
      await prefs.remove('auth_username');
      await prefs.remove('auth_token');
      await prefs.remove('auth_user_id');
      await prefs.remove('last_username');
    } catch (e) {
      print('✗ Error clearing all user data: $e');
      rethrow;
    }
  }
  
  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final username = await getAuthUsername();
    final isLoggedIn = token != null && token.isNotEmpty && username != null && username.isNotEmpty;
    return isLoggedIn;
  }
  
  // Validasi token (opsional - untuk cek session masih valid)
  static Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;
      
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('✗ Token validation error: $e');
      return false;
    }
  }
  
  // Get current user info
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('auth_username');
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('auth_user_id');
      
      if (username == null || token == null || userId == null) {
        return null;
      }
      
      return {
        'username': username,
        'token': token,
        'id': userId,
      };
    } catch (e) {
      print('✗ Error getting current user: $e');
      return null;
    }
  }
  
  // Clear semua data autentikasi
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_username');
      await prefs.remove('auth_token');
      await prefs.remove('auth_user_id');
    } catch (e) {
      print('✗ Error clearing auth data: $e');
      rethrow;
    }
  }
  
  // Helper untuk mendapatkan username yang benar untuk storage
  static Future<String?> getStorageUsername() async {
    final authUsername = await getAuthUsername();
    final lastUsername = await getLastUsername();
    final storageUsername = authUsername ?? lastUsername;
    
    return storageUsername;
  }
}