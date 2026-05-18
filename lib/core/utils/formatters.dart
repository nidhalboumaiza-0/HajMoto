import 'package:intl/intl.dart';

/// Centralized formatters used across the app.
/// Avoids re-creating identical NumberFormat / DateFormat instances everywhere.

/// Currency format for Tunisian Dinar.
final NumberFormat appCurrencyFormat =
    NumberFormat.currency(symbol: 'TND ', decimalDigits: 2);

/// Date + time format used in tables / lists.
final DateFormat appDateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

/// Short date format for charts / compact labels.
final DateFormat appShortDateFormat = DateFormat('dd/MM');

/// Date-only format used in filter pickers.
final DateFormat appDateFormat = DateFormat('dd/MM/yyyy');

/// Format a large number into a compact human-readable string.
/// e.g. 1 200 000 → "1.2M", 45 600 → "45.6K"
String formatCompactNumber(double value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return value.toStringAsFixed(0);
}
