import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/order_api_service.dart';
import 'package:supermarket_manager_system/domain/models/dashboard_summary.dart';
import 'package:supermarket_manager_system/domain/models/dashboard_transaction.dart';
import 'package:supermarket_manager_system/presentation/widgets/dashboard_header.dart';

class DashboardContent extends StatefulWidget {
  final String fullName;
  final String roleLabel;
  final bool isCompact;
  final String currentTimeText;
  final VoidCallback onProfileTap;

  const DashboardContent({
    super.key,
    required this.fullName,
    required this.roleLabel,
    required this.isCompact,
    required this.currentTimeText,
    required this.onProfileTap,
  });

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final _service = OrderApiService();
  DashboardSummary? _summary;
  List<DashboardTransaction> _transactions = [];
  bool _loadingSummary = true;
  bool _loadingTransactions = true;

  // Transactions table state
  final TextEditingController _searchCtrl = TextEditingController();
  int _pageSize = 10;
  int _currentPage = 0;

  List<DashboardTransaction> get _filteredTransactions {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _transactions;
    return _transactions
        .where(
          (t) =>
              t.orderNo.toLowerCase().contains(q) ||
              t.cashierName.toLowerCase().contains(q) ||
              t.paymentMethod.toLowerCase().contains(q) ||
              t.status.toLowerCase().contains(q),
        )
        .toList();
  }

  List<DashboardTransaction> get _pagedTransactions {
    final all = _filteredTransactions;
    final start = _currentPage * _pageSize;
    if (start >= all.length) return [];
    return all.sublist(start, min(start + _pageSize, all.length));
  }

  @override
  void initState() {
    super.initState();
    _loadSummary();
    _loadTransactions();
    _searchCtrl.addListener(() => setState(() => _currentPage = 0));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    try {
      final s = await _service.getDashboardSummary();
      if (mounted) {
        setState(() {
          _summary = s;
          _loadingSummary = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingSummary = false;
        });
      }
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final t = await _service.getTodayTransactions();
      if (mounted) {
        setState(() {
          _transactions = t;
          _loadingTransactions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingTransactions = false;
        });
      }
    }
  }

  String _fmtMoney(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M₫';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)},000₫';
    return '${v.toStringAsFixed(0)}₫';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(widget.isCompact ? 16 : 24),
              children: [
                _buildColorCards(),
                const SizedBox(height: 16),
                _buildStatsGrid(),
                const SizedBox(height: 16),
                _buildChartRow(),
                const SizedBox(height: 16),
                _buildTransactionsTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return DashboardHeader(
      fullName: widget.fullName,
      roleLabel: widget.roleLabel,
      currentTimeText: widget.currentTimeText,
      isCompact: widget.isCompact,
      onProfileTap: widget.onProfileTap,
      timeChipColor: const Color(0xFF4CAF50),
      avatarColor: const Color(0xFF1E293B),
    );
  }

  Widget _buildColorCards() {
    if (_loadingSummary) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final s = _summary;
    final cards = [
      _ColorCardData(
        color: const Color(0xFF2E7D32),
        title: 'Today Sales',
        value: s != null ? _fmtMoney(s.todaySales) : '—',
        icon: Icons.attach_money_rounded,
      ),
      _ColorCardData(
        color: const Color(0xFFE53935),
        title: 'Expired',
        value: s != null ? s.expiredProducts.toString() : '—',
        icon: Icons.warning_amber_rounded,
      ),
      _ColorCardData(
        color: const Color(0xFFFFC107),
        title: 'Today Invoice',
        value: s != null ? s.todayInvoiceCount.toString() : '—',
        icon: Icons.receipt_long_outlined,
        darkText: true,
      ),
      _ColorCardData(
        color: const Color(0xFF4CAF50),
        title: 'New Products',
        value: s != null ? s.newProductsCount.toString() : '—',
        icon: Icons.shopping_bag_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final cols = w >= 1200 ? 4 : (w >= 700 ? 2 : 1);
        final cw = (w - (cols - 1) * 12) / cols;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map(
                (c) => SizedBox(
                  width: cw,
                  child: _ColorCard(data: c),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    if (_loadingSummary) return const SizedBox.shrink();
    final s = _summary;
    final items = [
      (
        'Suppliers',
        s != null ? s.supplierCount.toString() : '—',
        Icons.local_shipping_outlined,
        const Color(0xFFFED7AA),
        const Color(0xFFC2410C),
      ),
      (
        'Invoices',
        s != null ? s.invoiceCount.toString() : '—',
        Icons.shopping_cart_outlined,
        const Color(0xFFE9D5FF),
        const Color(0xFF6B21A8),
      ),
      (
        'Current Month Sales',
        s != null ? _fmtMoney(s.currentMonthSales) : '—',
        Icons.percent_rounded,
        const Color(0xFFFDE68A),
        const Color(0xFFB45309),
      ),
      (
        'Last 3 Month Record',
        s != null ? _fmtMoney(s.last3MonthSales) : '—',
        Icons.bar_chart_rounded,
        const Color(0xFFFBCFE8),
        const Color(0xFF9D174D),
      ),
      (
        'Last 6 Month Record Sales',
        s != null ? _fmtMoney(s.last6MonthSales) : '—',
        Icons.area_chart_rounded,
        const Color(0xFFBFDBFE),
        const Color(0xFF1D4ED8),
      ),
      (
        'Users',
        s != null ? s.userCount.toString() : '—',
        Icons.group_outlined,
        const Color(0xFFBBF7D0),
        const Color(0xFF166534),
      ),
      (
        'Available Products',
        s != null ? s.availableProductsCount.toString() : '—',
        Icons.shopping_bag_outlined,
        const Color(0xFFFED7AA),
        const Color(0xFFC2410C),
      ),
      (
        'Current Year Revenue',
        s != null ? _fmtMoney(s.currentYearRevenue) : '—',
        Icons.star_outline_rounded,
        const Color(0xFFFEF08A),
        const Color(0xFFA16207),
      ),
    ];

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final cols = w >= 1200 ? 3 : (w >= 800 ? 2 : 1);
        final cw = (w - (cols - 1) * 12) / cols;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) => SizedBox(
                  width: cw,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8EAED)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: item.$4,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.$3, color: item.$5, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.$1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.$2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: Color(0xFF1A1D21),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildChartRow() {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              _SalesLineChartCard(transactions: _transactions),
              const SizedBox(height: 16),
              _TopProductsPieChart(topProducts: _summary?.topProducts ?? []),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: _SalesLineChartCard(transactions: _transactions)),
            const SizedBox(width: 16),
            Expanded(
              child: _TopProductsPieChart(
                topProducts: _summary?.topProducts ?? [],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionsTable() {
    final today = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dayLabel =
        '${weekdays[today.weekday - 1]} ${today.day}th ${months[today.month - 1]}, ${today.year}';

    final filtered = _filteredTransactions;
    final paged = _pagedTransactions;
    final totalPages = (filtered.length / _pageSize).ceil();
    final isCompact = widget.isCompact;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF1A1D21),
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  const TextSpan(text: "Today's ("),
                  TextSpan(
                    text: dayLabel,
                    style: const TextStyle(color: Color(0xFF4CAF50)),
                  ),
                  const TextSpan(text: ") "),
                  const TextSpan(
                    text: "Transactions",
                    style: TextStyle(color: Color(0xFF92400E)),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Show ', style: TextStyle(fontSize: 13)),
                          DropdownButton<int>(
                            value: _pageSize,
                            isDense: true,
                            items: [5, 10, 25, 50]
                                .map(
                                  (n) => DropdownMenuItem(
                                    value: n,
                                    child: Text('$n'),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _pageSize = v;
                                  _currentPage = 0;
                                });
                              }
                            },
                          ),
                          const Text(
                            ' entries',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          isDense: true,
                          prefixIcon: const Icon(Icons.search, size: 18),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          hintText: 'Search...',
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Text('Show ', style: TextStyle(fontSize: 13)),
                      DropdownButton<int>(
                        value: _pageSize,
                        isDense: true,
                        items: [5, 10, 25, 50]
                            .map(
                              (n) =>
                                  DropdownMenuItem(value: n, child: Text('$n')),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _pageSize = v;
                              _currentPage = 0;
                            });
                          }
                        },
                      ),
                      const Text(' entries', style: TextStyle(fontSize: 13)),
                      const Spacer(),
                      const Text('Search: ', style: TextStyle(fontSize: 13)),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            hintText: 'Search...',
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          if (_loadingTransactions)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF7F8FA),
                ),
                dataRowMinHeight: 56,
                dataRowMaxHeight: 56,
                headingRowHeight: 48,
                horizontalMargin: 20,
                columnSpacing: 24,
                columns: const [
                  DataColumn(
                    label: Text(
                      'ORDER ID',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFF4A5568),
                        letterSpacing: 0.03,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'PAYMENT',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFF4A5568),
                        letterSpacing: 0.03,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'AMOUNT',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFF4A5568),
                        letterSpacing: 0.03,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ATTENDANT',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFF4A5568),
                        letterSpacing: 0.03,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'STATUS',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFF4A5568),
                        letterSpacing: 0.03,
                      ),
                    ),
                  ),
                ],
                rows: paged.map((t) {
                  final isPaid = t.status.toLowerCase() == 'paid';
                  final isLink = t.paymentMethod.toLowerCase() == 'transfer';
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          t.orderNo,
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(
                        isLink
                            ? Text(
                                t.paymentMethod,
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                ),
                              )
                            : Text(t.paymentMethod),
                      ),
                      DataCell(
                        Text(
                          _fmtMoney(t.totalPayable),
                          style: const TextStyle(color: Color(0xFF2E7D32)),
                        ),
                      ),
                      DataCell(Text(t.cashierName)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            t.status,
                            style: TextStyle(
                              color: isPaid
                                  ? const Color(0xFF166534)
                                  : const Color(0xFF92400E),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filtered.isEmpty
                            ? 'No entries found'
                            : 'Showing ${_currentPage * _pageSize + 1} to ${min((_currentPage + 1) * _pageSize, filtered.length)} of ${filtered.length} entries',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _currentPage > 0
                                ? () => setState(() => _currentPage--)
                                : null,
                            child: const Text('Previous'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _currentPage < totalPages - 1
                                ? () => setState(() => _currentPage++)
                                : null,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Text(
                        filtered.isEmpty
                            ? 'No entries found'
                            : 'Showing ${_currentPage * _pageSize + 1} to ${min((_currentPage + 1) * _pageSize, filtered.length)} of ${filtered.length} entries',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _currentPage > 0
                                ? () => setState(() => _currentPage--)
                                : null,
                            child: const Text('Previous'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _currentPage < totalPages - 1
                                ? () => setState(() => _currentPage++)
                                : null,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Color top card ───────────────────────────────────────────────────────────

class _ColorCardData {
  final Color color;
  final String title;
  final String value;
  final IconData icon;
  final bool darkText;
  const _ColorCardData({
    required this.color,
    required this.title,
    required this.value,
    required this.icon,
    this.darkText = false,
  });
}

class _ColorCard extends StatelessWidget {
  final _ColorCardData data;
  const _ColorCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final fg = data.darkText ? const Color(0xFF1A1D21) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.darkText
                  ? Colors.black.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: fg, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View',
                  style: TextStyle(
                    color: fg.withValues(alpha: 0.9),
                    decoration: TextDecoration.underline,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sales Line Chart ─────────────────────────────────────────────────────────

class _SalesLineChartCard extends StatelessWidget {
  final List<DashboardTransaction> transactions;
  const _SalesLineChartCard({required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Group by date from createdAt
    final Map<String, double> dailyMap = {};
    for (final t in transactions) {
      final key = t.createdAt.length >= 10
          ? t.createdAt.substring(0, 10)
          : t.createdAt;
      dailyMap[key] = (dailyMap[key] ?? 0) + t.totalPayable;
    }
    // Add today if no data
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    if (dailyMap.isEmpty) {
      dailyMap[todayKey] = 0;
    }
    final sortedKeys = dailyMap.keys.toList()..sort();
    final points = sortedKeys.map((k) => dailyMap[k]!).toList();
    final maxVal = points.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.square, color: Color(0xFF2E7D32), size: 14),
              SizedBox(width: 4),
              Text(
                'Daily Sales',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Sales Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _LineChartPainter(
                values: points,
                labels: sortedKeys,
                maxValue: maxVal == 0 ? 1 : maxVal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double maxValue;

  _LineChartPainter({
    required this.values,
    required this.labels,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final gridPaint = Paint()
      ..color = const Color(0xFFE8EAED)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF2E7D32).withValues(alpha: 0.3),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    final dotPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;

    const padLeft = 50.0, padBottom = 28.0, padRight = 8.0, padTop = 8.0;
    final chartW = size.width - padLeft - padRight;
    final chartH = size.height - padBottom - padTop;

    // Grid lines
    for (int i = 0; i <= 4; i++) {
      final y = padTop + chartH * (1 - i / 4);
      canvas.drawLine(
        Offset(padLeft, y),
        Offset(padLeft + chartW, y),
        gridPaint,
      );
      // Y label
      final labelVal = (maxValue * i / 4);
      final String yLabel = labelVal >= 1000
          ? '${(labelVal / 1000).toStringAsFixed(0)},000'
          : labelVal.toStringAsFixed(0);
      final tp = TextPainter(
        text: TextSpan(
          text: yLabel,
          style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Points
    final pts = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x =
          padLeft +
          (values.length == 1 ? chartW / 2 : i * chartW / (values.length - 1));
      final y = padTop + chartH * (1 - values[i] / maxValue);
      pts.add(Offset(x, y));
    }

    // Fill area
    if (pts.length >= 2) {
      final fillPath = Path()..moveTo(pts.first.dx, size.height - padBottom);
      for (final p in pts) {
        fillPath.lineTo(p.dx, p.dy);
      }
      fillPath.lineTo(pts.last.dx, size.height - padBottom);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
    }

    // Line
    if (pts.length >= 2) {
      final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (int i = 1; i < pts.length; i++) {
        linePath.lineTo(pts[i].dx, pts[i].dy);
      }
      canvas.drawPath(linePath, linePaint);
    }

    // Dots + X labels
    for (int i = 0; i < pts.length; i++) {
      canvas.drawCircle(pts[i], 4, dotPaint);
      final label = labels[i].length >= 10 ? labels[i].substring(5) : labels[i];
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(pts[i].dx - tp.width / 2, size.height - padBottom + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) => old.values != values;
}

// ─── Top Products Pie Chart ───────────────────────────────────────────────────

class _TopProductsPieChart extends StatelessWidget {
  final List<TopProduct> topProducts;
  const _TopProductsPieChart({required this.topProducts});

  @override
  Widget build(BuildContext context) {
    if (topProducts.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8EAED)),
        ),
        child: const Text(
          'No product data',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    final total = topProducts.fold<int>(0, (sum, p) => sum + p.totalQty);
    final colors = [
      const Color(0xFF2E7D32), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Violet
    ];

    final items = List.generate(topProducts.length, (i) {
      final p = topProducts[i];
      return _PieSlice(
        p.name,
        colors[i % colors.length],
        total > 0 ? p.totalQty / total : 0.0,
      );
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 12, height: 4, color: item.color),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 110),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),
          const Text(
            'Top Selling Products',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _PieChartPainter(items: items),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieSlice {
  final String label;
  final Color color;
  final double ratio;
  const _PieSlice(this.label, this.color, this.ratio);
}

class _PieChartPainter extends CustomPainter {
  final List<_PieSlice> items;
  const _PieChartPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 8;
    var startAngle = -pi / 2;

    for (final item in items) {
      final sweep = 2 * pi * item.ratio;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle,
        sweep,
        true,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter old) => false;
}
