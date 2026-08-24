// ignore_for_file: unused_element, unused_element_parameter

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/domain/models/user_detail.dart';
import 'package:supermarket_manager_system/presentation/pages/login_page.dart';
import 'package:supermarket_manager_system/presentation/pages/customers_page.dart';
import 'package:supermarket_manager_system/presentation/pages/dashboard_content.dart';
import 'package:supermarket_manager_system/presentation/pages/orders_page.dart';
import 'package:supermarket_manager_system/presentation/pages/profile_content_page.dart';
import 'package:supermarket_manager_system/presentation/pages/revenue_report_page.dart';
import 'package:supermarket_manager_system/presentation/pages/creditors_page.dart';
import 'package:supermarket_manager_system/presentation/pages/users_page.dart';
import 'package:supermarket_manager_system/presentation/pages/discount.dart';
import 'package:supermarket_manager_system/presentation/pages/suppliers_page.dart';
import 'package:supermarket_manager_system/presentation/pages/supplier_detail_page.dart';
import 'package:supermarket_manager_system/presentation/pages/list_category_screen.dart';
import 'package:supermarket_manager_system/presentation/pages/products_page.dart';
import 'package:supermarket_manager_system/presentation/pages/expiration_page.dart';
import 'package:supermarket_manager_system/presentation/pages/product_detail_page.dart';
import 'package:supermarket_manager_system/presentation/widgets/change_password_dialog.dart';
import 'package:supermarket_manager_system/presentation/theme/app_theme.dart';

enum _AdminTab {
  dashboard,
  users,
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
  reports,
  creditors,
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({
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
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  _AdminTab _selectedTab = _AdminTab.dashboard;
  UserDetail? _editingProfile;
  int? _selectedProductId;
  int? _selectedSupplierId;
  late DateTime _now;
  Timer? _clockTimer;

  _AdminTab _tabFromKey(String key) {
    return switch (key) {
      'users' => _AdminTab.users,
      'orders' => _AdminTab.orders,
      'customers' => _AdminTab.customers,
      'discount' => _AdminTab.discount,
      'suppliers' => _AdminTab.suppliers,
      'categories' => _AdminTab.categories,
      'products' => _AdminTab.products,
      'expired' => _AdminTab.expired,
      'profile' => _AdminTab.profile,
      'profile-edit' => _AdminTab.profileEdit,
      'reports' => _AdminTab.reports,
      'creditors' => _AdminTab.creditors,
      _ => _AdminTab.dashboard,
    };
  }

  String _pathForTab(_AdminTab tab) {
    return switch (tab) {
      _AdminTab.dashboard => '/admin/dashboard',
      _AdminTab.users => '/admin/users',
      _AdminTab.orders => '/admin/orders',
      _AdminTab.customers => '/admin/customers',
      _AdminTab.discount => '/admin/discount',
      _AdminTab.suppliers => '/admin/suppliers',
      _AdminTab.categories => '/admin/categories',
      _AdminTab.supplierDetail => '/admin/suppliers',
      _AdminTab.products => '/admin/products',
      _AdminTab.expired => '/admin/expired',
      _AdminTab.productDetail => '/admin/expired',
      _AdminTab.profile => '/admin/profile',
      _AdminTab.profileEdit => '/admin/profile/edit',
      _AdminTab.reports => '/admin/reports',
      _AdminTab.creditors => '/admin/creditors',
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
  void didUpdateWidget(covariant AdminDashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabKey != oldWidget.initialTabKey) {
      _selectedTab = _tabFromKey(widget.initialTabKey);
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _selectTab(_AdminTab tab, {bool notifyRouter = true}) {
    setState(() => _selectedTab = tab);
    if (notifyRouter) {
      widget.onNavigatePath?.call(_pathForTab(tab));
    }
    final isCompact = MediaQuery.sizeOf(context).width < 1100;
    if (isCompact) {
      Navigator.of(context).maybePop();
    }
  }

  void _openProfileEdit(UserDetail detail) {
    setState(() {
      _editingProfile = detail;
      _selectedTab = _AdminTab.profileEdit;
    });
    widget.onNavigatePath?.call(_pathForTab(_AdminTab.profileEdit));
    final isCompact = MediaQuery.sizeOf(context).width < 1100;
    if (isCompact) {
      Navigator.of(context).maybePop();
    }
  }

  void _openProductDetail(int productId) {
    setState(() {
      _selectedProductId = productId;
      _selectedTab = _AdminTab.productDetail;
    });
  }

  void _closeProductDetail() {
    setState(() {
      _selectedTab = _AdminTab.expired; // Go back to expired tab
    });
  }

  void _openSupplierDetail(int supplierId) {
    setState(() {
      _selectedSupplierId = supplierId;
      _selectedTab = _AdminTab.supplierDetail;
    });
  }

  void _closeSupplierDetail() {
    setState(() {
      _selectedSupplierId = null;
      _selectedTab = _AdminTab.suppliers;
    });
  }

  void _onProfileUpdated(UserDetail detail) {
    setState(() {
      _editingProfile = detail;
      _selectedTab = _AdminTab.profile;
    });
    widget.onNavigatePath?.call(_pathForTab(_AdminTab.profile));
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

    if (widget.onLogoutRequested != null) {
      widget.onLogoutRequested!();
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  String _formatClock(DateTime dateTime) {
    final hour12 = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute:$second $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1100;

        return Scaffold(
          key: _scaffoldKey,
          drawer: isCompact
              ? Drawer(
                  width: 250,
                  child: _SidebarMenu(
                    selectedTab: _selectedTab,
                    onSelectTab: _selectTab,
                    onLogout: _logout,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isCompact)
                  SizedBox(
                    width: 248,
                    child: _SidebarMenu(
                      selectedTab: _selectedTab,
                      onSelectTab: _selectTab,
                      onLogout: _logout,
                    ),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      switch (_selectedTab) {
                        _AdminTab.dashboard => DashboardContent(
                          fullName: widget.fullName,
                          roleLabel: 'Administrator',
                          isCompact: isCompact,
                          currentTimeText: _formatClock(_now),
                          onProfileTap: () => _selectTab(_AdminTab.profile),
                        ),
                        _AdminTab.users => UsersContent(
                          fullName: widget.fullName,
                          isCompact: isCompact,
                          currentTimeText: _formatClock(_now),
                          onProfileTap: () => _selectTab(_AdminTab.profile),
                        ),
                        _AdminTab.orders => OrdersContent(
                          fullName: widget.fullName,
                          isCompact: isCompact,
                          currentTimeText: _formatClock(_now),
                          roleLabel: 'Administrator',
                          onProfileTap: () => _selectTab(_AdminTab.profile),
                        ),
                        _AdminTab.customers => CustomersContent(
                          fullName: widget.fullName,
                          isCompact: isCompact,
                          currentTimeText: _formatClock(_now),
                          onProfileTap: () => _selectTab(_AdminTab.profile),
                        ),
                        _AdminTab.discount => DiscountsContent(
                          fullName: widget.fullName,
                          isCompact: isCompact,
                          currentTimeText: _formatClock(_now),
                          onProfileTap: () => _selectTab(_AdminTab.profile),
                        ),
                        _AdminTab.suppliers => SuppliersContent(
                          fullName: widget.fullName,
                          isCompact: isCompact,
                          currentTimeText: _formatClock(_now),
                          onProfileTap: () => _selectTab(_AdminTab.profile),
                          basePath: 'admin',
                          onSupplierDetailTap: _openSupplierDetail,
                        ),
                        _AdminTab.categories => ListCategoryScreen(
                          fullName: widget.fullName,
                          isCompact: isCompact,
                          currentTimeText: _formatClock(_now),
                          onProfileTap: () => _selectTab(_AdminTab.profile),
                        ),
                        _AdminTab.supplierDetail =>
                          _selectedSupplierId != null
                              ? SupplierDetailPage(
                                  supplierId: _selectedSupplierId!,
                                  basePath: 'admin',
                                  onBack: _closeSupplierDetail,
                                )
                              : Container(),
                        _AdminTab.products => ProductsContent(
                          fullName: widget.fullName,
                          isCompact: isCompact,
                          currentTimeText: _formatClock(_now),
                          onProfileTap: () => _selectTab(_AdminTab.profile),
                        ),
                        _AdminTab.expired => ExpirationContent(
                          fullName: widget.fullName,
                          isCompact: isCompact,
                          currentTimeText: _formatClock(_now),
                          onProfileTap: () => _selectTab(_AdminTab.profile),
                          onProductDetailTap: _openProductDetail,
                        ),
                        _AdminTab.productDetail =>
                          _selectedProductId != null
                              ? ProductDetailContent(
                                  productId: _selectedProductId!,
                                  onBack: _closeProductDetail,
                                )
                              : Container(),
                        _AdminTab.profile => _ProfileContent(
                          fullName: widget.fullName,
                          userId: widget.userId,
                          isCompact: isCompact,
                          currentTimeText: _formatClock(_now),
                          onEditProfile: _openProfileEdit,
                        ),
                        _AdminTab.profileEdit => _ProfileEditContent(
                          userId: widget.userId,
                          initialDetail: _editingProfile,
                          isCompact: isCompact,
                          currentTimeText: _formatClock(_now),
                          onSaved: _onProfileUpdated,
                          onCancel: () => _selectTab(_AdminTab.profile),
                        ),
                        _AdminTab.reports => RevenueReportPage(
                          fullName: widget.fullName,
                          isCompact: isCompact,
                          currentTimeText: _formatClock(_now),
                          onProfileTap: () => _selectTab(_AdminTab.profile),
                        ),
                        _AdminTab.creditors => CreditorsPage(
                          fullName: widget.fullName,
                          roleLabel: 'Administrator',
                          isCompact: isCompact,
                          currentTimeText: _formatClock(_now),
                          onProfileTap: () => _selectTab(_AdminTab.profile),
                        ),
                      },
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SidebarMenu extends StatelessWidget {
  const _SidebarMenu({
    required this.selectedTab,
    required this.onSelectTab,
    required this.onLogout,
  });

  final _AdminTab selectedTab;
  final ValueChanged<_AdminTab> onSelectTab;
  final VoidCallback onLogout;

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
                _LogoBox(),
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
                    _SidebarItem(
                      label: 'Dashboard',
                      icon: Icons.dashboard_outlined,
                      active: selectedTab == _AdminTab.dashboard,
                      onTap: () => onSelectTab(_AdminTab.dashboard),
                    ),
                    _SidebarItem(
                      label: 'Users',
                      icon: Icons.people_outline,
                      active: selectedTab == _AdminTab.users,
                      onTap: () => onSelectTab(_AdminTab.users),
                    ),
                    _SidebarItem(
                      label: 'Orders',
                      icon: Icons.receipt_long_outlined,
                      active: selectedTab == _AdminTab.orders,
                      onTap: () => onSelectTab(_AdminTab.orders),
                    ),
                    _SidebarItem(
                      label: 'Customer',
                      icon: Icons.person_outline,
                      active: selectedTab == _AdminTab.customers,
                      onTap: () => onSelectTab(_AdminTab.customers),
                    ),
                    _SidebarItem(
                      label: 'Discount',
                      icon: Icons.local_offer_outlined,
                      active: selectedTab == _AdminTab.discount,
                      onTap: () => onSelectTab(_AdminTab.discount),
                    ),
                    _SidebarItem(
                      label: 'Suppliers',
                      icon: Icons.local_shipping_outlined,
                      active:
                          selectedTab == _AdminTab.suppliers ||
                          selectedTab == _AdminTab.supplierDetail,
                      onTap: () => onSelectTab(_AdminTab.suppliers),
                    ),
                    _SidebarItem(
                      label: 'Category',
                      icon: Icons.category_outlined,
                      active: selectedTab == _AdminTab.categories,
                      onTap: () => onSelectTab(_AdminTab.categories),
                    ),
                    _SidebarItem(
                      label: 'Products',
                      icon: Icons.inventory_2_outlined,
                      active: selectedTab == _AdminTab.products,
                      onTap: () => onSelectTab(_AdminTab.products),
                    ),
                    _SidebarItem(
                      label: 'Creditors',
                      icon: Icons.account_balance_wallet_outlined,
                      active: selectedTab == _AdminTab.creditors,
                      onTap: () => onSelectTab(_AdminTab.creditors),
                    ),
                    _SidebarItem(
                      label: 'Expired',
                      icon: Icons.warning_amber_outlined,
                      active: selectedTab == _AdminTab.expired,
                      onTap: () => onSelectTab(_AdminTab.expired),
                    ),
                    _SidebarItem(
                      label: 'Reports',
                      icon: Icons.bar_chart_outlined,
                      active: selectedTab == _AdminTab.reports,
                      onTap: () => onSelectTab(_AdminTab.reports),
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
            child: _SidebarItem(
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

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.fullName,
    required this.isCompact,
    required this.currentTimeText,
    required this.onProfileTap,
  });

  final String fullName;
  final bool isCompact;
  final String currentTimeText;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isCompact)
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.menu),
                    ),
                  )
                else
                  const SizedBox(width: 48),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentTimeText,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          fullName.isEmpty ? 'Administrator' : fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Text(
                          'Administrator',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: onProfileTap,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                _TopCards(),
                SizedBox(height: 16),
                _StatsGrid(),
                SizedBox(height: 16),
                _ChartRow(),
                SizedBox(height: 16),
                _TransactionTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent({
    required this.fullName,
    required this.userId,
    required this.isCompact,
    required this.currentTimeText,
    required this.onEditProfile,
  });

  final String fullName;
  final int userId;
  final bool isCompact;
  final String currentTimeText;
  final ValueChanged<UserDetail> onEditProfile;

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  @override
  Widget build(BuildContext context) {
    return ProfileViewContent(
      fullName: widget.fullName,
      userId: widget.userId,
      isCompact: widget.isCompact,
      currentTimeText: widget.currentTimeText,
      onEditProfile: widget.onEditProfile,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.fullName,
    required this.isCompact,
    required this.currentTimeText,
  });

  final String fullName;
  final bool isCompact;
  final String currentTimeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isCompact)
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            )
          else
            const Text(
              'My Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentTimeText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fullName.isEmpty ? 'Administrator' : fullName),
                  const Text(
                    'Administrator',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.detail});

  final UserDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    detail.fullname.isNotEmpty
                        ? detail.fullname[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin ID - ${detail.id}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Text(
                  detail.fullname.isEmpty ? 'Administrator' : detail.fullname,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    detail.status.isEmpty ? 'Unknown' : detail.status,
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _ProfileBullet(
            text: detail.phone.isEmpty ? 'Phone: N/A' : detail.phone,
          ),
          _ProfileBullet(
            text: detail.email.isEmpty ? 'Email: N/A' : detail.email,
          ),
          _ProfileBullet(
            text: detail.idCard.isEmpty ? 'ID Card: N/A' : detail.idCard,
          ),
          _ProfileBullet(
            text: detail.dob.isEmpty ? 'DOB: N/A' : 'DOB: ${detail.dob}',
          ),
          _ProfileBullet(
            text: detail.address.isEmpty ? 'Address: N/A' : detail.address,
          ),
          _ProfileBullet(text: detail.role.isEmpty ? 'Role: N/A' : detail.role),
          const SizedBox(height: 20),
          const Text(
            'Authentication Details',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Divider(color: Color(0xFFE2E8F0)),
          _AuthDetailRow(label: 'User Name :', value: detail.username),
          _AuthDetailRow(label: 'Last Login:', value: detail.lastLogin),
          const _AuthDetailRow(label: 'Registered:', value: '—'),
        ],
      ),
    );
  }
}

class _ProfileBullet extends StatelessWidget {
  const _ProfileBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF334155),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _AuthDetailRow extends StatelessWidget {
  const _AuthDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSettingsCard extends StatelessWidget {
  const _ProfileSettingsCard({
    required this.detail,
    required this.onEditProfile,
  });

  final UserDetail detail;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Settings',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          const _ProfileInputLabel('Email'),
          const SizedBox(height: 6),
          _ProfileTextField(initialValue: detail.email, readOnly: true),
          const SizedBox(height: 14),
          const _ProfileInputLabel('Phone *'),
          const SizedBox(height: 6),
          _ProfileTextField(
            initialValue: detail.phone,
            hintText: 'Enter phone',
            readOnly: true,
          ),
          const SizedBox(height: 14),
          const _ProfileInputLabel('ID Card Number'),
          const SizedBox(height: 6),
          _ProfileTextField(
            initialValue: detail.idCard,
            hintText: 'Enter ID card number',
            readOnly: true,
          ),
          const SizedBox(height: 14),
          const _ProfileInputLabel('Date Of Birth'),
          const SizedBox(height: 6),
          _ProfileTextField(
            initialValue: detail.dob,
            hintText: 'yyyy-MM-dd',
            readOnly: true,
          ),
          const SizedBox(height: 14),
          const _ProfileInputLabel('Address'),
          const SizedBox(height: 6),
          _ProfileTextField(
            initialValue: detail.address,
            hintText: 'Sample address',
            maxLines: 4,
            readOnly: true,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onEditProfile,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Update Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => ChangePasswordDialog(userId: detail.id),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7280),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Change Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileEditContent extends StatefulWidget {
  const _ProfileEditContent({
    required this.userId,
    required this.initialDetail,
    required this.isCompact,
    required this.currentTimeText,
    required this.onSaved,
    required this.onCancel,
  });

  final int userId;
  final UserDetail? initialDetail;
  final bool isCompact;
  final String currentTimeText;
  final ValueChanged<UserDetail> onSaved;
  final VoidCallback onCancel;

  @override
  State<_ProfileEditContent> createState() => _ProfileEditContentState();
}

class _ProfileEditContentState extends State<_ProfileEditContent> {
  @override
  Widget build(BuildContext context) {
    return ProfileEditContent(
      userId: widget.userId,
      initialDetail: widget.initialDetail,
      isCompact: widget.isCompact,
      currentTimeText: widget.currentTimeText,
      onSaved: widget.onSaved,
      onCancel: widget.onCancel,
    );
  }
}

class _ProfileInputLabel extends StatelessWidget {
  const _ProfileInputLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF475569),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ProfileEditableField extends StatelessWidget {
  const _ProfileEditableField({
    required this.controller,
    this.enabled = true,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final bool enabled;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DCE5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DCE5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.initialValue,
    this.hintText,
    this.readOnly = false,
    this.maxLines = 1,
  });

  final String initialValue;
  final String? hintText;
  final bool readOnly;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DCE5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DCE5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
        ),
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox();

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
      child: const Icon(Icons.store, color: Color(0xFF2E7D32), size: 22),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
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

class _TopCards extends StatelessWidget {
  const _TopCards();

  @override
  Widget build(BuildContext context) {
    const cards = [
      _CardData(
        color: Color(0xFF4CAF50),
        title: 'Today Sales',
        value: '250,000đ',
      ),
      _CardData(color: Color(0xFFF472B6), title: 'Expired', value: '0'),
      _CardData(
        color: Color(0xFFFACC15),
        title: 'Today Invoice',
        value: '3',
        darkText: true,
      ),
      _CardData(color: Color(0xFF7DD3FC), title: 'New Products', value: '4'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1200 ? 4 : (width >= 700 ? 2 : 1);
        final cardWidth = (width - (columns - 1) * 12) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map(
                (card) => SizedBox(
                  width: cardWidth,
                  child: _ColorCard(
                    color: card.color,
                    title: card.title,
                    value: card.value,
                    darkText: card.darkText,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _CardData {
  const _CardData({
    required this.color,
    required this.title,
    required this.value,
    this.darkText = false,
  });

  final Color color;
  final String title;
  final String value;
  final bool darkText;
}

class _ColorCard extends StatelessWidget {
  const _ColorCard({
    required this.color,
    required this.title,
    required this.value,
    this.darkText = false,
  });

  final Color color;
  final String title;
  final String value;
  final bool darkText;

  @override
  Widget build(BuildContext context) {
    final fg = darkText ? const Color(0xFF1A1D21) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: fg, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      ('Suppliers', '4'),
      ('Invoices', '12'),
      ('Current Month Sales', '1,850,000đ'),
      ('Last 3 Month Record', '5,220,000đ'),
      ('Last 6 Month Record Sales', '9,100,000đ'),
      ('Users', '3'),
      ('Available Products', '4'),
      ('Current Year Revenue', '18,500,000đ'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => SizedBox(
              width: 290,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8EAED)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ChartRow extends StatelessWidget {
  const _ChartRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width < 900) {
          return const Column(
            children: [
              _ChartCard(title: 'Sales Overview'),
              SizedBox(height: 16),
              _ChartCard(title: 'Top Selling Products'),
            ],
          );
        }
        return const Row(
          children: [
            Expanded(child: _ChartCard(title: 'Sales Overview')),
            SizedBox(width: 16),
            Expanded(child: _ChartCard(title: 'Top Selling Products')),
          ],
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Chart Placeholder',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTable extends StatelessWidget {
  const _TransactionTable();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Today's Transactions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          DataTable(
            columns: const [
              DataColumn(label: Text('Order ID')),
              DataColumn(label: Text('Payment')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Attendant')),
              DataColumn(label: Text('Status')),
            ],
            rows: const [
              DataRow(
                cells: [
                  DataCell(Text('ORD-201')),
                  DataCell(Text('Cash')),
                  DataCell(Text('125,000đ')),
                  DataCell(Text('John')),
                  DataCell(Text('Paid')),
                ],
              ),
              DataRow(
                cells: [
                  DataCell(Text('ORD-202')),
                  DataCell(Text('Transfer')),
                  DataCell(Text('85,400đ')),
                  DataCell(Text('Jane')),
                  DataCell(Text('Paid')),
                ],
              ),
              DataRow(
                cells: [
                  DataCell(Text('ORD-203')),
                  DataCell(Text('POS')),
                  DataCell(Text('39,600đ')),
                  DataCell(Text('John')),
                  DataCell(Text('Pending')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
