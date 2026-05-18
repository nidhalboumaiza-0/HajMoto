/// Application-wide constants
/// Centralized place for all magic numbers and configuration values
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Gestion Stock - Moto Parts';
  static const String appVersion = '1.0.0';
  static const String shopName = 'Motorcycle Spare Parts Shop';

  // TVA (Tax) Rate - Tunisia 19%
  static const double tvaRate = 0.19;

  // Stock Thresholds
  static const int defaultLowStockThreshold = 5;
  static const int outOfStockThreshold = 0;

  // Supabase Tables
  static const String productsTable = 'products';
  static const String salesTable = 'sales';
  static const String clientsTable = 'clients';
  static const String invoicesTable = 'invoices';

  // Pagination
  static const int defaultPageSize = 50;

  // CSV Import
  static const List<String> csvHeaders = [
    'referenceCode',
    'name',
    'category',
    'purchasePrice',
    'sellingPrice',
    'quantity',
  ];

  // Date Formats
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayDateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String invoiceDateFormat = 'dd/MM/yyyy HH:mm:ss';
}
