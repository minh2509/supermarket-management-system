// On web use stub (localhost). On Android/iOS use io (10.0.2.2 on Android).
import 'api_constants_io.dart'
    if (dart.library.html) 'api_constants_stub.dart'
    as host;

class ApiConstants {
  /// Android emulator: 10.0.2.2 (host). Other: localhost.
  static String get baseUrl => host.getBaseUrl();
  static const String loginPath = '/api/auth/login';
  static const String forgotPasswordPath = '/api/auth/forgot-password';
  static const String verifyOtpPath = '/api/auth/verify-otp';
  static const String resetPasswordPath = '/api/auth/reset-password';
  static const String usersPath = '/api/users';
  static const String userRolesPath = '/api/users/roles';
  static const String ordersPath = '/api/orders';
  static const String customersPath = '/api/customers';
  static const String suppliersPath = '/api/suppliers';
  static const String categoriesPath = '/api/categories';
  static const String productsPath = '/api/products';
  static const String dashboardPath = '/api/orders/dashboard';
  static const String dashboardTransactionsPath =
      '/api/orders/today-transactions';
  static const String revenueReportPath = '/api/reports/revenue';
  static const String discountsPath = '/api/discounts';
  static const String shiftsPath = '/api/shifts';
}
