import 'local_storage.dart';

class CurrencyHelper {
  static String _getCurrencySymbol(String currency) {
    switch (currency) {
      case '\$/USD': return '\$';
      case '€/EUR': return '€';
      case '¥/JPY': return '¥';
      default: return 'Rp';
    }
  }

  static Future<String> getCurrencySymbol() async {
    final currency = await LocalStorage.getCurrency() ?? 'Rp/IDR';
    return _getCurrencySymbol(currency);
  }

  static String formatNumber(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  static Future<String> formatCurrency(double amount, {bool withSign = false, bool? isIncome}) async {
    final symbol = await getCurrencySymbol();
    final formattedNumber = formatNumber(amount);
    
    if (withSign && isIncome != null) {
      return '${isIncome ? '+' : '-'}$symbol $formattedNumber';
    }
    
    return '$symbol $formattedNumber';
  }

  static Future<String> formatCurrencyWithSign(double amount, bool isIncome) async {
    return formatCurrency(amount, withSign: true, isIncome: isIncome);
  }
}