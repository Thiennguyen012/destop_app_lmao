import 'package:intl/intl.dart';

class AppUtils {
  static String formatCurrency(double amount, {String currency = 'VND'}) {
    // Format số tiền với dấu . ngăn cách hàng ngàn
    final formatter = NumberFormat('#,###.##', 'vi_VN');
    final formatted = formatter.format(amount);
    return '$formatted $currency';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'vi_VN').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'vi_VN').format(date);
  }

  static String getMonthName(int month) {
    final monthNames = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return monthNames[month - 1];
  }
}
