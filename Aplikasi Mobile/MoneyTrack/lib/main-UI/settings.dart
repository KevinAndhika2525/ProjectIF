import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helper/colors.dart';
import 'login.dart';
import '../helper/local_storage.dart';
import 'manage.dart';
import '../helper/theme_provider.dart';
import '../helper/authService.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedCurrency = 'Rp/IDR';
  String _selectedDateFormat = 'DD/MM/YYYY';
  
  final List<String> _currencies = [
    'Rp/IDR',
    '\$/USD',
    '€/EUR',
    '¥/JPY',
  ];
  
  final List<String> _dateFormats = [
    'DD/MM/YYYY',
    'DD/MMM/YYYY',
    'DD-MM-YYYY',
    'DD-MMM-YYYY',
    'D Month, YYYY'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final savedCurrency = await LocalStorage.getCurrency();
    final savedDateFormat = await LocalStorage.getDateFormat();
    
    if (mounted) {
      setState(() {
        _selectedCurrency = savedCurrency ?? 'Rp/IDR';
        _selectedDateFormat = savedDateFormat ?? 'DD/MM/YYYY';
      });
    }
  }

  Future<void> _saveCurrency(String currency) async {
    await LocalStorage.saveCurrency(currency);
    setState(() {
      _selectedCurrency = currency;
    });
  }

  Future<void> _saveDateFormat(String format) async {
    await LocalStorage.saveDateFormat(format);
    setState(() {
      _selectedDateFormat = format;
    });
  }

  void _navigateToManageCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManageCategoriesPage()),
    );
  }

  Future<void> _logout() async {
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
          'Are you sure you want to logout?\n\nYour transaction data will be saved.',
          style: TextStyle(fontFamily: 'RobotoSlab'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'RobotoSlab'),
            ),
          ),
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

    if (confirm) {
      // Hanya logout, TIDAK hapus data
      await AuthService.logout();
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'RobotoSlab',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appColors.appBarColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preferences Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Text(
                'PREFERENCES',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontFamily: 'RobotoSlab',
                ),
              ),
            ),
            
            // Currency Setting Card
            Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.currency_exchange,
                      color: Colors.blue[700],
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Currency',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'RobotoSlab',
                        ),
                      ),
                    ),
                    Container(
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: appColors.lightGreyCard),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCurrency,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          icon: const Icon(Icons.arrow_drop_down, size: 20),
                          style: TextStyle(
                            fontSize: 14,
                            color: appColors.textPrimary,
                            fontFamily: 'RobotoSlab',
                          ),
                          items: _currencies.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(fontFamily: 'RobotoSlab'),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _saveCurrency(newValue);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Date Format Setting Card
            Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.blue[700],
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Date Format',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'RobotoSlab',
                        ),
                      ),
                    ),
                    Container(
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: appColors.lightGreyCard),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDateFormat,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          icon: const Icon(Icons.arrow_drop_down, size: 20),
                          style: TextStyle(
                            fontSize: 14,
                            color: appColors.textPrimary,
                            fontFamily: 'RobotoSlab',
                          ),
                          items: _dateFormats.map((String value) {
                            String displayText;
                            
                            switch (value) {
                              case 'DD/MM/YYYY':
                                displayText = 'DD/MM/YYYY';
                                break;
                              case 'DD/MMM/YYYY':
                                displayText = 'DD/MMM/YYYY';
                                break;
                              case 'DD-MM-YYYY':
                                displayText = 'DD-MM-YYYY';
                                break;
                              case 'DD-MMM-YYYY':
                                displayText = 'DD-MMM/YYYY';
                                break;
                              case 'D Month, YYYY':
                                displayText = 'D Month, YYYY';
                                break;
                              default:
                                displayText = value;
                            }
                            
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                displayText,
                                style: const TextStyle(fontFamily: 'RobotoSlab'),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _saveDateFormat(newValue);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Manage Categories Card
            Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: _navigateToManageCategories,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.category,
                        color: Colors.blue[700],
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Manage Categories',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'RobotoSlab',
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[500],
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Appearance Card
            Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.color_lens,
                      color: Colors.blue[700],
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'RobotoSlab',
                        ),
                      ),
                    ),
                    Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                      activeThumbColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            
            // // Security Section
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            //   child: Text(
            //     'SECURITY',
            //     style: TextStyle(
            //       fontSize: 14,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.grey,
            //       fontFamily: 'RobotoSlab',
            //     ),
            //   ),
            // ),
            
            // Logout Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(229, 115, 115, 0.9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'RobotoSlab',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // App Version Info
            Center(
              child: Text(
                '© 2025 MoneyTrack v0.19',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                  fontFamily: 'RobotoSlab',
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}