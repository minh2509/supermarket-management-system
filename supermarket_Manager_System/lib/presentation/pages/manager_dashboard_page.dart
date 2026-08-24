import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/domain/models/user_detail.dart';
import 'package:supermarket_manager_system/presentation/pages/customers_page.dart';
import 'package:supermarket_manager_system/presentation/pages/dashboard_content.dart';
import 'package:supermarket_manager_system/presentation/pages/orders_page.dart';
import 'package:supermarket_manager_system/presentation/pages/profile_content_page.dart';
import 'package:supermarket_manager_system/presentation/pages/discount.dart';
import 'package:supermarket_manager_system/presentation/pages/suppliers_page.dart';
import 'package:supermarket_manager_system/presentation/pages/supplier_detail_page.dart';
import 'package:supermarket_manager_system/presentation/pages/list_category_screen.dart';
import 'package:supermarket_manager_system/presentation/pages/products_page.dart';
import 'package:supermarket_manager_system/presentation/pages/expiration_page.dart';
import 'package:supermarket_manager_system/presentation/pages/product_detail_page.dart';
import 'package:supermarket_manager_system/presentation/pages/creditors_page.dart';
import 'package:supermarket_manager_system/presentation/theme/app_theme.dart';

enum _ManagerTab {
  dashboard,
  orders,
  customers,
  discount,
  suppliers,
  categories,
  supplierDetail,
  products,
  expired,
  profile,
  profileEdit,
  productDetail,
  creditors,
}

class ManagerDashboardPage extends StatefulWidget {
  const ManagerDashboardPage({
    super.key,
    required this.fullName,
    required this.userId,
    required this.initialTabKey,
    this.onNavigatePath,
    this.onLogoutRequested,
  });

  final String fullName;
  final int userId;
  final String initialTabKey;
  final ValueChanged<String>? onNavigatePath;
  final VoidCallback? onLogoutRequested;

  @override
  State<ManagerDashboardPage> createState() => _ManagerDashboardPageState();
}

class _ManagerDashboardPageState extends State<ManagerDashboardPage> {
  _ManagerTab _selectedTab = _ManagerTab.dashboard;
  UserDetail? _editingProfile;
  int? _selectedProductId;
  int? _selectedSupplierId;
  late DateTime _now;
  Timer? _clockTimer;

  _ManagerTab _tabFromKey(String key) {
    return switch (key) {
      'profile' => _ManagerTab.profile,
      'orders' => _ManagerTab.orders,
      'customers' => _ManagerTab.customers,
      'discount' => _ManagerTab.discount,
      'suppliers' => _ManagerTab.suppliers,
      'categories' => _ManagerTab.categories,
      'products' => _ManagerTab.products,
      'expired' => _ManagerTab.expired,
      'creditors' => _ManagerTab.creditors,
      'profile-edit' => _ManagerTab.profileEdit,
      _ => _ManagerTab.dashboard,
    };
  }

  String _pathForTab(_ManagerTab tab) {
    return switch (tab) {
      _ManagerTab.dashboard => '/manager/dashboard',
      _ManagerTab.orders => '/manager/orders',
      _ManagerTab.customers => '/manager/customers',
      _ManagerTab.discount => '/manager/discount',
      _ManagerTab.suppliers => '/manager/suppliers',
      _ManagerTab.categories => '/manager/categories',
      _ManagerTab.supplierDetail => '/manager/suppliers',
      _ManagerTab.products => '/manager/products',
      _ManagerTab.expired => '/manager/expired',
      _ManagerTab.productDetail => '/manager/expired',
      _ManagerTab.creditors => '/manager/creditors',
      _ManagerTab.profile => '/manager/profile',
      _ManagerTab.profileEdit => '/manager/profile/edit',
    };
  }

  @override
  void initState() {
    super.initState();
    _selectedTab = _tabFromKey(widget.initialTabKey);
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ManagerDashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabKey != oldWidget.initialTabKey) {
      _selectedTab = _tabFromKey(widget.initialTabKey);
    }
  }

  String _formatClock(DateTime dateTime) {
    final hour12 = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute:$second $amPm';
  }

  void _selectTab(_ManagerTab tab, {bool notifyRouter = true}) {
    setState(() => _selectedTab = tab);
    if (notifyRouter) {
      widget.onNavigatePath?.call(_pathForTab(tab));
    }
    final isCompact = MediaQuery.sizeOf(context).width < 1100;
    if (isCompact) {
      Navigator.of(context).maybePop();
    }
  }

  void _openProductDetail(int productId) {
    setState(() {
      _selectedProductId = productId;
      _selectedTab = _ManagerTab.productDetail;
    });
  }

  void _closeProductDetail() {
    setState(() {
      _selectedTab = _ManagerTab.expired; // Go back to expired tab
    });
  }

  void _openSupplierDetail(int supplierId) {
    setState(() {
      _selectedSupplierId = supplierId;
      _selectedTab = _ManagerTab.supplierDetail;
    });
  }

  void _closeSupplierDetail() {
    setState(() {
      _selectedSupplierId = null;
      _selectedTab = _ManagerTab.suppliers;
    });
  }

  void _openProfileEdit(UserDetail detail) {
    setState(() {
      _editingProfile = detail;
      _selectedTab = _ManagerTab.profileEdit;
    });
    widget.onNavigatePath?.call(_pathForTab(_ManagerTab.profileEdit));
  }

  void _onProfileUpdated(UserDetail detail) {
    setState(() {
      _editingProfile = detail;
      _selectedTab = _ManagerTab.profile;
    });
    widget.onNavigatePath?.call(_pathForTab(_ManagerTab.profile));
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }
    widget.onLogoutRequested?.call();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1100;
        return Scaffold(
          drawer: isCompact
              ? Drawer(
                  width: 250,
                  child: _ManagerSidebar(
                    onLogout: _logout,
                    selectedTab: _selectedTab,
                    onDashboardTap: () => _selectTab(_ManagerTab.dashboard),
                    onOrdersTap: () => _selectTab(_ManagerTab.orders),
                    onCustomersTap: () => _selectTab(_ManagerTab.customers),
                    onDiscountTap: () => _selectTab(_ManagerTab.discount),
                    onSuppliersTap: () => _selectTab(_ManagerTab.suppliers),
                    onCategoriesTap: () => _selectTab(_ManagerTab.categories),
                    onProductsTap: () => _selectTab(_ManagerTab.products),
                    onCreditorsTap: () => _selectTab(_ManagerTab.creditors),
                    onExpiredTap: () => _selectTab(_ManagerTab.expired),
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isCompact)
                  SizedBox(
                    width: 248,
                    child: _ManagerSidebar(
                      onLogout: _logout,
                      selectedTab: _selectedTab,
                      onDashboardTap: () => _selectTab(_ManagerTab.dashboard),
                      onOrdersTap: () => _selectTab(_ManagerTab.orders),
                      onCustomersTap: () => _selectTab(_ManagerTab.customers),
                      onDiscountTap: () => _selectTab(_ManagerTab.discount),
                      onSuppliersTap: () => _selectTab(_ManagerTab.suppliers),
                      onCategoriesTap: () => _selectTab(_ManagerTab.categories),
                      onProductsTap: () => _selectTab(_ManagerTab.products),
                      onCreditorsTap: () => _selectTab(_ManagerTab.creditors),
                      onExpiredTap: () => _selectTab(_ManagerTab.expired),
                    ),
                  ),
                Expanded(
                  child: switch (_selectedTab) {
                    _ManagerTab.dashboard => DashboardContent(
                      fullName: widget.fullName,
                      roleLabel: 'Manager',
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onProfileTap: () => _selectTab(_ManagerTab.profile),
                    ),
                    _ManagerTab.orders => OrdersContent(
                      fullName: widget.fullName,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      roleLabel: 'Manager',
                      onProfileTap: () => _selectTab(_ManagerTab.profile),
                    ),
                    _ManagerTab.customers => CustomersContent(
                      fullName: widget.fullName,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onProfileTap: () => _selectTab(_ManagerTab.profile),
                    ),
                    _ManagerTab.discount => DiscountsContent(
                      fullName: widget.fullName,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onProfileTap: () => _selectTab(_ManagerTab.profile),
                    ),
                    _ManagerTab.suppliers => SuppliersContent(
                      fullName: widget.fullName,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onProfileTap: () => _selectTab(_ManagerTab.profile),
                      basePath: 'manager',
                      onSupplierDetailTap: _openSupplierDetail,
                    ),
                    _ManagerTab.categories => ListCategoryScreen(
                      fullName: widget.fullName,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onProfileTap: () => _selectTab(_ManagerTab.profile),
                    ),
                    _ManagerTab.supplierDetail =>
                      _selectedSupplierId != null
                          ? SupplierDetailPage(
                              supplierId: _selectedSupplierId!,
                              basePath: 'manager',
                              onBack: _closeSupplierDetail,
                            )
                          : Container(),
                    _ManagerTab.products => ProductsContent(
                      fullName: widget.fullName,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onProfileTap: () => _selectTab(_ManagerTab.profile),
                    ),
                    _ManagerTab.expired => ExpirationContent(
                      fullName: widget.fullName,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onProfileTap: () => _selectTab(_ManagerTab.profile),
                      onProductDetailTap: _openProductDetail,
                    ),
                    _ManagerTab.productDetail =>
                      _selectedProductId != null
                          ? ProductDetailContent(
                              productId: _selectedProductId!,
                              onBack: _closeProductDetail,
                            )
                          : Container(),
                    _ManagerTab.creditors => CreditorsPage(
                      fullName: widget.fullName,
                      roleLabel: 'Manager',
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onProfileTap: () => _selectTab(_ManagerTab.profile),
                    ),
                    _ManagerTab.profile => ProfileViewContent(
                      fullName: widget.fullName,
                      userId: widget.userId,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onEditProfile: _openProfileEdit,
                    ),
                    _ManagerTab.profileEdit => ProfileEditContent(
                      userId: widget.userId,
                      initialDetail: _editingProfile,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onSaved: _onProfileUpdated,
                      onCancel: () => _selectTab(_ManagerTab.profile),
                    ),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ManagerSidebar extends StatelessWidget {
  const _ManagerSidebar({
    required this.onLogout,
    required this.selectedTab,
    required this.onDashboardTap,
    required this.onOrdersTap,
    required this.onCustomersTap,
    required this.onDiscountTap,
    required this.onSuppliersTap,
    required this.onCategoriesTap,
    required this.onProductsTap,
    required this.onCreditorsTap,
    required this.onExpiredTap,
  });

  final VoidCallback onLogout;
  final _ManagerTab selectedTab;
  final VoidCallback onDashboardTap;
  final VoidCallback onOrdersTap;
  final VoidCallback onCustomersTap;
  final VoidCallback onDiscountTap;
  final VoidCallback onSuppliersTap;
  final VoidCallback onCategoriesTap;
  final VoidCallback onProductsTap;
  final VoidCallback onCreditorsTap;
  final VoidCallback onExpiredTap;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, 20 + topInset, 20, 20),
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            child: const Row(
              children: [
                _ManagerLogo(),
                SizedBox(width: 10),
                Text(
                  'SUPERMART',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    _ManagerSidebarItem(
                      label: 'Dashboard',
                      icon: Icons.dashboard_outlined,
                      active: selectedTab == _ManagerTab.dashboard,
                      onTap: onDashboardTap,
                    ),
                    _ManagerSidebarItem(
                      label: 'Orders',
                      icon: Icons.receipt_long_outlined,
                      active: selectedTab == _ManagerTab.orders,
                      onTap: onOrdersTap,
                    ),
                    _ManagerSidebarItem(
                      label: 'Customer',
                      icon: Icons.person_outline,
                      active: selectedTab == _ManagerTab.customers,
                      onTap: onCustomersTap,
                    ),
                    _ManagerSidebarItem(
                      label: 'Discount',
                      icon: Icons.local_offer_outlined,
                      active: selectedTab == _ManagerTab.discount,
                      onTap: onDiscountTap,
                    ),
                    _ManagerSidebarItem(
                      label: 'Suppliers',
                      icon: Icons.local_shipping_outlined,
                      active:
                          selectedTab == _ManagerTab.suppliers ||
                          selectedTab == _ManagerTab.supplierDetail,
                      onTap: onSuppliersTap,
                    ),
                    _ManagerSidebarItem(
                      label: 'Category',
                      icon: Icons.category_outlined,
                      active: selectedTab == _ManagerTab.categories,
                      onTap: onCategoriesTap,
                    ),
                    _ManagerSidebarItem(
                      label: 'Products',
                      icon: Icons.inventory_2_outlined,
                      active: selectedTab == _ManagerTab.products,
                      onTap: onProductsTap,
                    ),
                    _ManagerSidebarItem(
                      label: 'Creditors',
                      icon: Icons.account_balance_wallet_outlined,
                      active: selectedTab == _ManagerTab.creditors,
                      onTap: onCreditorsTap,
                    ),
                    _ManagerSidebarItem(
                      label: 'Expired',
                      icon: Icons.warning_amber_outlined,
                      active: selectedTab == _ManagerTab.expired,
                      onTap: onExpiredTap,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(color: Color.fromRGBO(255, 255, 255, 0.25), height: 1),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 10),
            child: _ManagerSidebarItem(
              label: 'Logout',
              icon: Icons.logout,
              onTap: onLogout,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerLogo extends StatelessWidget {
  const _ManagerLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.storefront_rounded,
        color: AppColors.primary,
        size: 22,
      ),
    );
  }
}

class _ManagerSidebarItem extends StatelessWidget {
  const _ManagerSidebarItem({
    required this.label,
    this.active = false,
    this.onTap,
    this.icon,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: active
            ? const Color.fromRGBO(255, 255, 255, 0.18)
            : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: active ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: ListTile(
        dense: true,
        onTap: onTap,
        leading: icon != null
            ? Icon(
                icon,
                color: Colors.white.withValues(alpha: active ? 1.0 : 0.7),
                size: 20,
              )
            : null,
        title: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
