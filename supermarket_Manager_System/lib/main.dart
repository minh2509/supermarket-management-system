import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:supermarket_manager_system/data/local/database_initializer.dart';
import 'package:supermarket_manager_system/presentation/pages/add_product_page.dart';
import 'package:supermarket_manager_system/presentation/pages/admin_dashboard_page.dart';
import 'package:supermarket_manager_system/presentation/pages/cashier_dashboard_page.dart';
import 'package:supermarket_manager_system/presentation/pages/cashier_open_shift_page.dart';
import 'package:supermarket_manager_system/presentation/pages/login_page.dart';
import 'package:supermarket_manager_system/presentation/pages/manager_dashboard_page.dart';
import 'package:supermarket_manager_system/presentation/pages/role_home_page.dart';
import 'package:supermarket_manager_system/presentation/pages/supplier_detail_page.dart';
import 'package:supermarket_manager_system/presentation/pages/forgot_password_page.dart';
import 'package:supermarket_manager_system/presentation/pages/verify_otp_page.dart';
import 'package:supermarket_manager_system/presentation/pages/set_new_password_page.dart';
import 'package:supermarket_manager_system/presentation/pages/product_detail_page.dart';
import 'package:supermarket_manager_system/presentation/theme/app_theme.dart';
import 'package:supermarket_manager_system/utils/app_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  try {
    await initDatabase();
  } catch (e, st) {
    debugPrint('initDatabase failed: $e\n$st');
  }
  try {
    AppSession.instance.clear();
  } catch (e, st) {
    debugPrint('AppSession.clear failed: $e\n$st');
  }
  runApp(const SupermarketManagerApp());
}

class SupermarketManagerApp extends StatelessWidget {
  const SupermarketManagerApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/login',
    refreshListenable: AppSession.instance,
    redirect: (context, state) {
      final path = state.uri.path;
      final isLoggedIn = AppSession.instance.isLoggedIn;
      final isPublicRoute =
          path == '/login' ||
          path == '/' ||
          path == '/forgot-password' ||
          path == '/verify-otp' ||
          path == '/set-new-password';

      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      if (isLoggedIn && (path == '/login' || path == '/')) {
        final roleId = AppSession.instance.roleId;
        final role = AppSession.instance.role.toLowerCase();
        if (roleId == 3 || role.contains('cashier')) {
          return '/cashier/open-shift';
        }
        if (role.contains('admin')) {
          return '/admin/dashboard';
        }
        if (role.contains('manager')) {
          return '/manager/dashboard';
        }
        return '/role-home';
      }

      // Role-based route guards for authenticated users
      if (isLoggedIn) {
        final roleId = AppSession.instance.roleId;
        final role = AppSession.instance.role.toLowerCase();
        final isCashier = roleId == 3 || role.contains('cashier');
        final isAdmin = role.contains('admin');
        final isManager = role.contains('manager');

        // Cashier cannot access /admin or /manager routes
        if (isCashier &&
            (path.startsWith('/admin') || path.startsWith('/manager'))) {
          return '/cashier/open-shift';
        }
        // Manager cannot access /admin routes
        if (isManager && path.startsWith('/admin')) {
          return '/manager/dashboard';
        }
        // Admin cannot access /cashier or /manager routes
        if (isAdmin &&
            (path.startsWith('/cashier') || path.startsWith('/manager'))) {
          return '/admin/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/login'),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return VerifyOtpPage(email: email);
        },
      ),
      GoRoute(
        path: '/set-new-password',
        builder: (context, state) {
          final otp = state.uri.queryParameters['otp'] ?? '';
          return SetNewPasswordPage(otp: otp);
        },
      ),
      GoRoute(
        path: '/admin',
        redirect: (context, state) {
          if (state.uri.path == '/admin') return '/admin/dashboard';
          return null;
        },
        routes: [
          GoRoute(
            path: 'add-product',
            pageBuilder: (context, state) {
              return MaterialPage(
                key: const ValueKey('admin-add-product'),
                child: AddProductPage(
                  basePath: 'admin',
                  fullName: AppSession.instance.fullName,
                ),
              );
            },
          ),
          GoRoute(
            path: 'products/detail/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return MaterialPage(
                key: ValueKey('admin-product-detail-$id'),
                child: ProductDetailPage(
                  productId: id,
                  basePath: 'admin',
                  fullName: AppSession.instance.fullName,
                ),
              );
            },
          ),
          GoRoute(
            path: 'supplier-detail/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return MaterialPage(
                key: ValueKey('admin-supplier-detail-$id'),
                child: SupplierDetailPage(supplierId: id, basePath: 'admin'),
              );
            },
          ),
          GoRoute(
            path: ':section',
            pageBuilder: (context, state) => NoTransitionPage(
              key: const ValueKey('admin-shell'),
              child: _buildAdminPage(
                context: context,
                initialTabKey: _resolveAdminTabKey(state),
              ),
            ),
          ),
          GoRoute(
            path: ':section/:subSection',
            pageBuilder: (context, state) => NoTransitionPage(
              key: const ValueKey('admin-shell'),
              child: _buildAdminPage(
                context: context,
                initialTabKey: _resolveAdminTabKey(state),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/role-home',
        builder: (context, state) {
          return RoleHomePage(
            role: AppSession.instance.role,
            fullName: AppSession.instance.fullName,
          );
        },
      ),
      GoRoute(
        path: '/cashier',
        redirect: (context, state) => '/cashier/open-shift',
      ),
      GoRoute(
        path: '/cashier/open-shift',
        builder: (context, state) =>
            CashierOpenShiftPage(fullName: AppSession.instance.fullName),
      ),
      GoRoute(
        path: '/cashier/:section',
        pageBuilder: (context, state) => NoTransitionPage(
          key: const ValueKey('cashier-shell'),
          child: _buildCashierPage(
            context: context,
            initialTabKey: _resolveCashierTabKey(state),
            initialPhone: _resolveCashierPhone(state),
            initialOrderId: _resolveCashierOrderId(state),
          ),
        ),
      ),
      GoRoute(
        path: '/cashier/:section/:subSection',
        pageBuilder: (context, state) => NoTransitionPage(
          key: const ValueKey('cashier-shell'),
          child: _buildCashierPage(
            context: context,
            initialTabKey: _resolveCashierTabKey(state),
            initialPhone: _resolveCashierPhone(state),
            initialOrderId: _resolveCashierOrderId(state),
          ),
        ),
      ),
      GoRoute(
        path: '/manager',
        redirect: (context, state) {
          if (state.uri.path == '/manager') return '/manager/dashboard';
          return null;
        },
        routes: [
          GoRoute(
            path: 'add-product',
            pageBuilder: (context, state) {
              return MaterialPage(
                key: const ValueKey('manager-add-product'),
                child: AddProductPage(
                  basePath: 'manager',
                  fullName: AppSession.instance.fullName,
                ),
              );
            },
          ),
          GoRoute(
            path: 'products/detail/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return MaterialPage(
                key: ValueKey('manager-product-detail-$id'),
                child: ProductDetailPage(
                  productId: id,
                  basePath: 'manager',
                  fullName: AppSession.instance.fullName,
                ),
              );
            },
          ),
          GoRoute(
            path: 'supplier-detail/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return MaterialPage(
                key: ValueKey('manager-supplier-detail-$id'),
                child: SupplierDetailPage(supplierId: id, basePath: 'manager'),
              );
            },
          ),
          GoRoute(
            path: ':section',
            pageBuilder: (context, state) => NoTransitionPage(
              key: const ValueKey('manager-dashboard'),
              child: _buildManagerPage(
                context: context,
                initialTabKey: _resolveManagerTabKey(state),
              ),
            ),
          ),
          GoRoute(
            path: ':section/:subSection',
            pageBuilder: (context, state) => NoTransitionPage(
              key: const ValueKey('manager-dashboard'),
              child: _buildManagerPage(
                context: context,
                initialTabKey: _resolveManagerTabKey(state),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  static Widget _buildAdminPage({
    required BuildContext context,
    required String initialTabKey,
  }) {
    final userId = AppSession.instance.userId;
    final fullName = AppSession.instance.fullName;
    if (userId == null) {
      return const LoginPage();
    }
    return AdminDashboardPage(
      key: const ValueKey('admin-dashboard-shell'),
      fullName: fullName,
      userId: userId,
      initialTabKey: initialTabKey,
      onNavigatePath: (path) {
        context.go(path);
      },
      onLogoutRequested: () {
        AppSession.instance.clear();
        context.go('/login');
      },
    );
  }

  static String _resolveAdminTabKey(GoRouterState state) {
    final section = state.pathParameters['section'] ?? 'dashboard';
    final subSection = state.pathParameters['subSection'];

    if (section == 'users') return 'users';
    if (section == 'orders') return 'orders';
    if (section == 'customers') return 'customers';
    if (section == 'discount') return 'discount';
    if (section == 'suppliers') return 'suppliers';
    if (section == 'categories') return 'categories';
    if (section == 'products') return 'products';
    if (section == 'expired') return 'expired';
    if (section == 'creditors') return 'creditors';
    if (section == 'reports') return 'reports';
    if (section == 'profile' && subSection == 'edit') return 'profile-edit';
    if (section == 'profile') return 'profile';
    return 'dashboard';
  }

  static Widget _buildManagerPage({
    required BuildContext context,
    required String initialTabKey,
  }) {
    final userId = AppSession.instance.userId;
    if (userId == null) {
      return const LoginPage();
    }
    return ManagerDashboardPage(
      key: const ValueKey('manager-dashboard-shell'),
      fullName: AppSession.instance.fullName,
      userId: userId,
      initialTabKey: initialTabKey,
      onNavigatePath: (path) => context.go(path),
      onLogoutRequested: () {
        AppSession.instance.clear();
        context.go('/login');
      },
    );
  }

  static Widget _buildCashierPage({
    required BuildContext context,
    required String initialTabKey,
    required String initialPhone,
    required int? initialOrderId,
  }) {
    final userId = AppSession.instance.userId;
    if (userId == null) {
      return const LoginPage();
    }
    return CashierDashboardPage(
      key: const ValueKey('cashier-dashboard-shell'),
      fullName: AppSession.instance.fullName,
      userId: userId,
      initialTabKey: initialTabKey,
      initialPhone: initialPhone,
      initialOrderId: initialOrderId,
      onNavigatePath: (path) => context.go(path),
      onLogoutRequested: () {
        AppSession.instance.clear();
        context.go('/login');
      },
    );
  }

  static String _resolveCashierTabKey(GoRouterState state) {
    final section = state.pathParameters['section'] ?? 'barcode-scanner';
    final subSection = state.pathParameters['subSection'];
    if (section == 'customers' && subSection == 'history') {
      return 'customer-history';
    }
    if (section == 'shift') return 'shift-info';
    if (section == 'shifts' && subSection == 'history') {
      return 'shift-history';
    }
    if (section == 'orders' && subSection == 'detail') {
      return 'order-detail';
    }
    if (section == 'profile' && subSection == 'edit') {
      return 'profile-edit';
    }
    if (section == 'profile') return 'profile';
    if (section == 'customers') return 'customers';
    return 'scanner';
  }

  static String _resolveCashierPhone(GoRouterState state) {
    return state.uri.queryParameters['phone'] ?? '';
  }

  static int? _resolveCashierOrderId(GoRouterState state) {
    return int.tryParse(state.uri.queryParameters['orderId'] ?? '');
  }

  static String _resolveManagerTabKey(GoRouterState state) {
    final section = state.pathParameters['section'] ?? 'dashboard';
    final subSection = state.pathParameters['subSection'];
    if (section == 'profile' && subSection == 'edit') return 'profile-edit';
    if (section == 'orders') return 'orders';
    if (section == 'customers') return 'customers';
    if (section == 'discount') return 'discount';
    if (section == 'suppliers') return 'suppliers';
    if (section == 'categories') return 'categories';
    if (section == 'products') return 'products';
    if (section == 'expired') return 'expired';
    if (section == 'creditors') return 'creditors';
    if (section == 'reports') return 'reports';
    if (section == 'profile') return 'profile';
    return 'dashboard';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Supermarket Manager',
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
