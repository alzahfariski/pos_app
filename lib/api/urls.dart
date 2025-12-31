import 'dart:io';

class Urls {
  // BASE URL
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  // AUTH
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  static String get verifyOtp => '$baseUrl/auth/verify-otp';
  static String get logout => '$baseUrl/auth/logout';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get updatePassword => '$baseUrl/auth/password';
  static String get updateProfile => '$baseUrl/auth/profile';
  static String get loginGoogle => '$baseUrl/auth/google';

  // User
  static String get getCurrentUser => '$baseUrl/user';

  // PRODUCTS
  static String get products => '$baseUrl/products';
  static String get uploadImageProduct => '$baseUrl/products/{id}/image';
  static String get productById => '$baseUrl/products/{id}';

  // Suppliers
  static String get suppliers => '$baseUrl/suppliers';
  static String get supplierById => '$baseUrl/suppliers/{id}';

  //Purchase
  static String get purchases => '$baseUrl/purchases';
  static String get purchaseById => '$baseUrl/purchases/{id}';

  //Cashiers
  static String get cashiers => '$baseUrl/cashiers';
  static String get cashierById => '$baseUrl/cashiers/{id}';

  // Inventory Correction
  static String get inventoryAdjustments => '$baseUrl/inventory/adjust';
  static String get inventoryOpname => '$baseUrl/inventory/opname';

  // POS
  static String get pos => '$baseUrl/pos';
  static String get transactionById => '$baseUrl/pos/{id}';
}
