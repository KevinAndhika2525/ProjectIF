import 'local_storage.dart';

class Formatter {
  static String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }
  
  static String _getFullMonthName(int month) {
    const fullMonthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return fullMonthNames[month - 1];
  }

  static Future<String> formatCurrency(double amount) async {
    final currency = await LocalStorage.getCurrency() ?? 'Rp/IDR';
    
    // Extract currency symbol
    String symbol;
    switch (currency) {
      case '\$/USD':
        symbol = '\$';
        break;
      case '€/EUR':
        symbol = '€';
        break;
      case '¥/JPY':
        symbol = '¥';
        break;
      default:
        symbol = 'Rp';
    }
    
    // Format number with commas
    final formattedNumber = amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    
    return '$symbol $formattedNumber';
  }
  
  static Future<String> formatCurrencyWithSign(double amount, bool isIncome) async {
    final formatted = await formatCurrency(amount.abs());
    return '${isIncome ? '+' : '-'}$formatted';
  }
  
  static Future<String> formatDate(DateTime date) async {
    final format = await LocalStorage.getDateFormat() ?? 'DD/MM/YYYY';
    
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final monthName = _getMonthName(date.month);
    final fullMonthName = _getFullMonthName(date.month);
    final dayWithoutZero = date.day.toString(); // Untuk format tanpa leading zero
    
    switch (format) {
      case 'DD/MM/YYYY':
        return '$day/$month/$year';
      case 'DD/MMM/YYYY':
        return '$day/$monthName/$year';
      case 'DD-MM-YYYY':
        return '$day-$month-$year';
      case 'DD-MMM-YYYY':
        return '$day-$monthName-$year';
      case 'D Month, YYYY':
        return '$dayWithoutZero $fullMonthName, $year';
      default: // Fallback to default
        return '$day/$month/$year';
    }
  }
  
  static Future<String> formatDateFromString(String dateString) async {
    try {
      // Coba parsing berbagai format
      DateTime? date;
      
      // Coba format DD/MM/YYYY
      final slashParts = dateString.split('/');
      if (slashParts.length == 3) {
        date = DateTime(
          int.parse(slashParts[2]),
          int.parse(slashParts[1]),
          int.parse(slashParts[0]),
        );
      } 
      // Coba format DD-MM-YYYY
      else {
        final dashParts = dateString.split('-');
        if (dashParts.length == 3) {
          // Cek apakah bagian kedua adalah angka atau nama bulan
          int month;
          if (RegExp(r'^\d+$').hasMatch(dashParts[1])) {
            // Jika angka
            month = int.parse(dashParts[1]);
          } else {
            // Jika nama bulan
            const monthNames = [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];
            month = monthNames.indexWhere((name) => 
              name.toLowerCase() == dashParts[1].toLowerCase()) + 1;
            if (month == 0) month = 1;
          }
          
          date = DateTime(
            int.parse(dashParts[2]),
            month,
            int.parse(dashParts[0]),
          );
        }
      }
      
      if (date != null) {
        return await formatDate(date);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    
    // Return current date if parsing fails
    return await formatDate(DateTime.now());
  }
}