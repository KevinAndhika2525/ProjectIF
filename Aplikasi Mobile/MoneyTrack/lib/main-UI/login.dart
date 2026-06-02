import 'package:flutter/material.dart';
import '../helper/colors.dart';
import 'home.dart';
import '../helper/authService.dart';
import '../helper/local_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;
  
  // Dummy users untuk forgot password
  final List<Map<String, String>> _demoUsers = [
    {'username': 'emilys', 'password': 'emilyspass', 'name': 'Emily'},
    {'username': 'michaelw', 'password': 'michaelwpass', 'name': 'Michael'},
    {'username': 'sophiab', 'password': 'sophiabpass', 'name': 'Sophia'},
  ];

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      
      if (isLoggedIn && mounted) {
        final user = await AuthService.getCurrentUser();
        if (user != null) {
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  username: user['username'],
                  userId: user['id'],
                  token: user['token'],
                ),
              ),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      print('Error checking session: $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Sembunyikan keyboard
      FocusScope.of(context).unfocus();
      
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        final result = await AuthService.login(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        if (result['success'] == true && mounted) {
          // Simpan username juga di LocalStorage untuk kompatibilitas
          await LocalStorage.saveUsername(_usernameController.text.trim());
          
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                username: result['user']['username'],
                userId: result['user']['id'],
                token: result['user']['token'],
              ),
            ),
            (route) => false,
          );
        } else if (mounted) {
          setState(() {
            _errorMessage = result['message'];
            _isLoading = false;
          });
          
          // Scroll ke error message
          _scrollToError();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Login failed: $e';
            _isLoading = false;
          });
          
          // Scroll ke error message
          _scrollToError();
        }
      }
    }
  }
  
  void _useDemoAccount(int index) {
    final user = _demoUsers[index];
    _usernameController.text = user['username']!;
    _passwordController.text = user['password']!;
  }

  void _forgotPassword() {
    // Sembunyikan keyboard
    FocusScope.of(context).unfocus();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            fontFamily: 'RobotoSlab',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Demo accounts (from dummyjson.com):',
                style: TextStyle(
                  fontFamily: 'RobotoSlab',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              ..._demoUsers.asMap().entries.map((entry) {
                final idx = entry.key;
                final user = entry.value;
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.person, size: 20),
                  title: Text(
                    '${user['name']}',
                    style: const TextStyle(fontFamily: 'RobotoSlab'),
                  ),
                  subtitle: Text(
                    'Username: ${user['username']}',
                    style: const TextStyle(fontFamily: 'RobotoSlab'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _useDemoAccount(idx);
                  },
                );
              }),
              const SizedBox(height: 10),
              const Text(
                '\nUsing DummyJSON API for authentication\nDemo accounts work without internet',
                style: TextStyle(
                  fontFamily: 'RobotoSlab',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(fontFamily: 'RobotoSlab'),
            ),
          ),
        ],
      ),
    );
  }
  
  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }
  
  void _scrollToError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _formKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username cannot be empty';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyTrack Login'),
        backgroundColor: appColors.appBarColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo dan judul
                      Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 133, 200, 255),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.asset(
                                'assets/Images/logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback jika gambar tidak ditemukan
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet,
                                      size: 60,
                                      color: Colors.blue,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          const Text(
                            'MoneyTrack',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontFamily: 'RobotoSlab',
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          const Text(
                            'Manage Your Finances Smartly',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontFamily: 'RobotoSlab',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      
                      // Error message
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color.fromARGB(255, 237, 160, 156)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Username field
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your username',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        ),
                        validator: _validateUsername,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(
                          fontFamily: 'RobotoSlab',
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword 
                                  ? Icons.visibility 
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        ),
                        obscureText: !_showPassword,
                        validator: _validatePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                        style: const TextStyle(
                          fontFamily: 'RobotoSlab',
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Forgot Password Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.blue,
                              fontFamily: 'RobotoSlab',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Login Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'RobotoSlab',
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'LOGIN',
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}