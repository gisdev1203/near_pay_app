import 'package:intl/intl.dart';

class DataFormatter {
  static String formatCurrency(double amount, {String currency = 'USD'}) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: currency,
    );
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMM dd, yyyy HH:mm');
    return formatter.format(dateTime);
  }

  static String formatPhoneNumber(String phoneNumber) {
    final formatted = phoneNumber.replaceAllMapped(
      RegExp(r'^(\d{3})(\d{3})(\d{4})$'),
      (match) => '(${match.group(1)}) ${match.group(2)}-${match.group(3)}',
    );
    return formatted;
  }

  // Additional formatting methods can be added as needed
}
