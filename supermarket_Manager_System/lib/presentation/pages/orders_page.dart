import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/order_api_service.dart';
import 'package:supermarket_manager_system/domain/models/order_detail.dart';
import 'package:supermarket_manager_system/domain/models/order_list_item.dart';
import 'package:supermarket_manager_system/presentation/widgets/dashboard_header.dart';
import 'package:supermarket_manager_system/presentation/widgets/order_detail_card.dart';

class OrdersContent extends StatefulWidget {
  const OrdersContent({
    super.key,
    required this.fullName,
    required this.isCompact,
    required this.currentTimeText,
    required this.roleLabel,
    required this.onProfileTap,
  });

  final String fullName;
  final bool isCompact;
  final String currentTimeText;
  final String roleLabel;
  final VoidCallback onProfileTap;

  @override
  State<OrdersContent> createState() => _OrdersContentState();
}

class _OrdersContentState extends State<OrdersContent> {
  final _orderApiService = OrderApiService();
  final _searchController = TextEditingController();
  final _ordersVerticalScrollController = ScrollController();
  final _ordersHorizontalScrollController = ScrollController();
  late Future<List<OrderListItem>> _ordersFuture;
  int? _selectedOrderId;
  Future<OrderDetail>? _orderDetailFuture;
  String _searchQuery = '';
  String _selectedStatusFilter = 'all';
  String _selectedPaymentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderApiService.getOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _ordersVerticalScrollController.dispose();
    _ordersHorizontalScrollController.dispose();
    super.dispose();
  }

  void _reloadOrders() {
    setState(() => _ordersFuture = _orderApiService.getOrders());
  }

  void _openOrderDetail(int orderId) {
    setState(() {
      _selectedOrderId = orderId;
      _orderDetailFuture = _orderApiService.getOrderDetail(orderId);
    });
  }

  void _backToOrderList() {
    setState(() {
      _selectedOrderId = null;
      _orderDetailFuture = null;
    });
  }

  String _money(double value) => 'đ${value.toStringAsFixed(0)}';

  String _paidText(double? paid) => paid == null ? '—' : _money(paid);

  Widget _buildDesktopOrdersTable(List<OrderListItem> orders) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        controller: _ordersVerticalScrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _ordersVerticalScrollController,
          primary: false,
          child: Scrollbar(
            controller: _ordersHorizontalScrollController,
            thumbVisibility: true,
            scrollbarOrientation: ScrollbarOrientation.bottom,
            child: SingleChildScrollView(
              controller: _ordersHorizontalScrollController,
              primary: false,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: const WidgetStatePropertyAll(
                  Color(0xFFF7F8FA),
                ),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A5568),
                  fontSize: 12,
                ),
                columns: const [
                  DataColumn(label: Text('ORDER ID')),
                  DataColumn(label: Text('CUSTOMER')),
                  DataColumn(label: Text('PHONE')),
                  DataColumn(label: Text('TOTAL')),
                  DataColumn(label: Text('DISCOUNT (%)')),
                  DataColumn(label: Text('PAYABLE')),
                  DataColumn(label: Text('PAID')),
                  DataColumn(label: Text('PAYMENT')),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('CASHIER')),
                  DataColumn(label: Text('ACTION')),
                ],
                rows: orders
                    .map(
                      (order) => DataRow(
                        cells: [
                          DataCell(Text(order.orderNo)),
                          DataCell(Text(order.customerName)),
                          DataCell(Text(order.customerPhone)),
                          DataCell(Text(_money(order.total))),
                          DataCell(
                            Text(order.discountPercent.toStringAsFixed(0)),
                          ),
                          DataCell(Text(_money(order.payable))),
                          DataCell(Text(_paidText(order.paid))),
                          DataCell(Text(order.paymentMethod)),
                          DataCell(_OrderStatusBadge(status: order.status)),
                          DataCell(Text(order.cashierName)),
                          DataCell(
                            TextButton(
                              onPressed: () => _openOrderDetail(order.id),
                              child: const Text('View'),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileOrderCard(OrderListItem order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE7ECF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10213A63),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderAvatar(label: order.orderNo),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.orderNo,
                      style: const TextStyle(
                        fontSize: 13,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7B1E2B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.orderDateTime,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8B7280),
                      ),
                    ),
                  ],
                ),
              ),
              _OrderStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 18),
          _OrderInfoRow(icon: Icons.phone_outlined, label: order.customerPhone),
          const SizedBox(height: 10),
          _OrderInfoRow(
            icon: Icons.point_of_sale_outlined,
            label: '${order.paymentMethod} - ${_paidText(order.paid)}',
          ),
          const SizedBox(height: 10),
          _OrderInfoRow(
            icon: Icons.badge_outlined,
            label: 'Cashier: ${order.cashierName}',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OrderMetricTile(
                  label: 'Payable',
                  value: _money(order.payable),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OrderMetricTile(
                  label: 'Discount',
                  value: '${order.discountPercent.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFF5EDED)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _openOrderDetail(order.id),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEFF4FF),
                foregroundColor: const Color(0xFF1F4ED8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedStatusFilter = 'all';
      _selectedPaymentFilter = 'all';
    });
  }

  List<OrderListItem> _filterOrders(List<OrderListItem> orders) {
    return orders.where((order) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          order.orderNo.toLowerCase().contains(query) ||
          order.customerName.toLowerCase().contains(query) ||
          order.customerPhone.toLowerCase().contains(query) ||
          order.id.toString().contains(query);
      final matchesStatus =
          _selectedStatusFilter == 'all' ||
          order.status.trim().toLowerCase() == _selectedStatusFilter;
      final matchesPayment =
          _selectedPaymentFilter == 'all' ||
          order.paymentMethod.trim().toLowerCase() == _selectedPaymentFilter;
      return matchesSearch && matchesStatus && matchesPayment;
    }).toList();
  }

  List<String> _extractPaymentOptions(List<OrderListItem> orders) {
    final methods =
        orders
            .map((order) => order.paymentMethod.trim())
            .where((method) => method.isNotEmpty && method != '—')
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return methods;
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.isCompact ? 16.0 : 24.0;
    return Container(
      color: const Color(0xFFF4F7FC),
      child: Column(
        children: [
          _OrdersHeader(
            fullName: widget.fullName,
            isCompact: widget.isCompact,
            currentTimeText: widget.currentTimeText,
            roleLabel: widget.roleLabel,
            onProfileTap: widget.onProfileTap,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _selectedOrderId == null
                        ? FutureBuilder<List<OrderListItem>>(
                            future: _ordersFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Cannot load orders: ${snapshot.error}',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: _reloadOrders,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final orders = snapshot.data ?? [];
                              final filteredOrders = _filterOrders(orders);
                              final paymentOptions = _extractPaymentOptions(
                                orders,
                              );

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _OrdersFilterBar(
                                    isCompact: widget.isCompact,
                                    searchController: _searchController,
                                    searchQuery: _searchQuery,
                                    selectedStatus: _selectedStatusFilter,
                                    selectedPayment: _selectedPaymentFilter,
                                    paymentOptions: paymentOptions,
                                    totalOrders: orders.length,
                                    filteredOrders: filteredOrders.length,
                                    onSearchChanged: (value) => setState(
                                      () => _searchQuery = value.trim(),
                                    ),
                                    onClearSearch: () => setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    }),
                                    onStatusChanged: (value) => setState(
                                      () => _selectedStatusFilter = value,
                                    ),
                                    onPaymentChanged: (value) => setState(
                                      () => _selectedPaymentFilter = value,
                                    ),
                                    onRefresh: _reloadOrders,
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: orders.isEmpty
                                        ? _OrdersEmptyState(
                                            icon: Icons.receipt_long_outlined,
                                            title: 'No orders found',
                                            message:
                                                'Orders will appear here after customers complete a purchase.',
                                            primaryLabel: 'Refresh orders',
                                            onPrimaryAction: _reloadOrders,
                                          )
                                        : filteredOrders.isEmpty
                                        ? _OrdersEmptyState(
                                            icon: Icons.filter_alt_off_outlined,
                                            title: 'No matching orders',
                                            message:
                                                'Try another keyword, status or payment filter to see more results.',
                                            primaryLabel: 'Clear filters',
                                            onPrimaryAction: _clearFilters,
                                          )
                                        : widget.isCompact
                                        ? ListView.separated(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: filteredOrders.length,
                                            separatorBuilder: (_, _) =>
                                                const SizedBox(height: 16),
                                            itemBuilder: (context, index) {
                                              final order =
                                                  filteredOrders[index];
                                              return _buildMobileOrderCard(
                                                order,
                                              );
                                            },
                                          )
                                        : _buildDesktopOrdersTable(
                                            filteredOrders,
                                          ),
                                  ),
                                ],
                              );
                            },
                          )
                        : FutureBuilder<OrderDetail>(
                            future: _orderDetailFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Cannot load order detail: ${snapshot.error}',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () =>
                                            _openOrderDetail(_selectedOrderId!),
                                        child: const Text('Retry'),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: _backToOrderList,
                                        child: const Text(
                                          'Back to Orders List',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final detail = snapshot.data;
                              if (detail == null) {
                                return const Center(
                                  child: Text('Order detail not found.'),
                                );
                              }

                              return SingleChildScrollView(
                                child: OrderDetailCard(
                                  detail: detail,
                                  moneyFormatter: _money,
                                  onBack: _backToOrderList,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({
    required this.fullName,
    required this.isCompact,
    required this.currentTimeText,
    required this.roleLabel,
    required this.onProfileTap,
  });

  final String fullName;
  final bool isCompact;
  final String currentTimeText;
  final String roleLabel;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return DashboardHeader(
      fullName: fullName,
      roleLabel: roleLabel,
      currentTimeText: currentTimeText,
      isCompact: isCompact,
      onProfileTap: onProfileTap,
      timeChipColor: const Color(0xFF2E7D32),
      avatarColor: const Color(0xFF1E293B),
    );
  }
}

class _OrdersFilterBar extends StatelessWidget {
  const _OrdersFilterBar({
    required this.isCompact,
    required this.searchController,
    required this.searchQuery,
    required this.selectedStatus,
    required this.selectedPayment,
    required this.paymentOptions,
    required this.totalOrders,
    required this.filteredOrders,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onStatusChanged,
    required this.onPaymentChanged,
    required this.onRefresh,
  });

  final bool isCompact;
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedStatus;
  final String selectedPayment;
  final List<String> paymentOptions;
  final int totalOrders;
  final int filteredOrders;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPaymentChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final actionButtonSize = isCompact ? 58.0 : 62.0;
    const statusValues = {'all', 'paid', 'pending', 'cancelled'};
    final paymentValues = <String>{
      'all',
      ...paymentOptions.map((e) => e.toLowerCase()),
    };
    final safeSelectedStatus = statusValues.contains(selectedStatus)
        ? selectedStatus
        : 'all';
    final safeSelectedPayment = paymentValues.contains(selectedPayment)
        ? selectedPayment
        : 'all';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Orders List',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$filteredOrders of $totalOrders orders',
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E3A8A),
                ),
                decoration: InputDecoration(
                  hintText: 'Search by order or customer',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 24,
                    color: Color(0xFF2E7D32),
                  ),
                  suffixIcon: searchQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: onClearSearch,
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFD8E2F1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: actionButtonSize,
              height: actionButtonSize,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x332563EB),
                    blurRadius: 12,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onRefresh,
                tooltip: 'Refresh',
                icon: const Icon(
                  Icons.swap_vert_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        isCompact
            ? Row(
                children: [
                  Expanded(
                    child: _OrdersFilterDropdown(
                      isCompact: isCompact,
                      value: safeSelectedStatus,
                      hint: 'Status',
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text(
                            'All status',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'paid',
                          child: Text('Paid', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text(
                            'Pending',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'cancelled',
                          child: Text(
                            'Cancelled',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: onStatusChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _OrdersFilterDropdown(
                      isCompact: isCompact,
                      value: safeSelectedPayment,
                      hint: 'Payment',
                      items: [
                        const DropdownMenuItem(
                          value: 'all',
                          child: Text(
                            'All payment',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...paymentOptions.map(
                          (method) => DropdownMenuItem(
                            value: method.toLowerCase(),
                            child: Text(
                              method,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: onPaymentChanged,
                    ),
                  ),
                ],
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: 148,
                    child: _OrdersFilterDropdown(
                      isCompact: isCompact,
                      value: safeSelectedStatus,
                      hint: 'Status',
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('All status'),
                        ),
                        DropdownMenuItem(value: 'paid', child: Text('Paid')),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'cancelled',
                          child: Text('Cancelled'),
                        ),
                      ],
                      onChanged: onStatusChanged,
                    ),
                  ),
                  SizedBox(
                    width: 148,
                    child: _OrdersFilterDropdown(
                      isCompact: isCompact,
                      value: safeSelectedPayment,
                      hint: 'Payment',
                      items: [
                        const DropdownMenuItem(
                          value: 'all',
                          child: Text('All payment'),
                        ),
                        ...paymentOptions.map(
                          (method) => DropdownMenuItem(
                            value: method.toLowerCase(),
                            child: Text(
                              method,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: onPaymentChanged,
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}

class _OrdersFilterDropdown extends StatelessWidget {
  const _OrdersFilterDropdown({
    required this.isCompact,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final bool isCompact;
  final String value;
  final String hint;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      items: items,
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 14 : 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Color(0xFFD8E2F1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.4),
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF2E7D32),
      ),
      style: TextStyle(
        color: const Color(0xFF1E3A8A),
        fontSize: isCompact ? 13 : 15,
        fontWeight: FontWeight.w600,
      ),
      dropdownColor: Colors.white,
    );
  }
}

class _OrdersEmptyState extends StatelessWidget {
  const _OrdersEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimaryAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0EAF4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, size: 34, color: const Color(0xFF9B2743)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onPrimaryAction,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF9B2743),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(primaryLabel),
          ),
        ],
      ),
    );
  }
}

class _OrderAvatar extends StatelessWidget {
  const _OrderAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final trimmed = label.trim();
    final suffix = trimmed.length >= 2
        ? trimmed.substring(trimmed.length - 2)
        : trimmed;
    return Container(
      width: 62,
      height: 62,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFF3D7DD), Color(0xFFE2E8F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        suffix.toUpperCase(),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF7B1E2B),
        ),
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  const _OrderInfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF7C8699)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }
}

class _OrderMetricTile extends StatelessWidget {
  const _OrderMetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4EBF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isPaid = normalized == 'paid';
    final isPending = normalized == 'pending';
    final bg = isPaid
        ? const Color(0xFFD1FAE5)
        : isPending
        ? const Color(0xFFFEF3C7)
        : const Color(0xFFFEE2E2);
    final fg = isPaid
        ? const Color(0xFF065F46)
        : isPending
        ? const Color(0xFF92400E)
        : const Color(0xFF991B1B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
