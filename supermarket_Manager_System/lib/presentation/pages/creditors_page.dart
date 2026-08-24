import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/presentation/widgets/dashboard_header.dart';

class CreditorsPage extends StatefulWidget {
  const CreditorsPage({
    super.key,
    required this.fullName,
    required this.roleLabel,
    required this.isCompact,
    required this.currentTimeText,
    this.onProfileTap,
  });

  final String fullName;
  final String roleLabel;
  final bool isCompact;
  final String currentTimeText;
  final VoidCallback? onProfileTap;

  @override
  State<CreditorsPage> createState() => _CreditorsPageState();
}

class _CreditorsPageState extends State<CreditorsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'all';

  static const List<_CreditorItem> _items = [
    _CreditorItem(
      invoiceNo: 'INV-2025-001',
      customerName: 'Nguyen Van A',
      phone: '0901234567',
      total: 250000,
      paid: 150000,
      balance: 100000,
      cashier: 'John',
      soldDate: '02/01/2025',
      dueDate: '15/01/2025',
    ),
    _CreditorItem(
      invoiceNo: 'INV-2025-002',
      customerName: 'Tran Thi B',
      phone: '0123456789',
      total: 420000,
      paid: 200000,
      balance: 220000,
      cashier: 'Jane',
      soldDate: '05/01/2025',
      dueDate: '20/01/2025',
    ),
    _CreditorItem(
      invoiceNo: 'INV-2025-003',
      customerName: 'Le Van C',
      phone: '0912345678',
      total: 185000,
      paid: 85000,
      balance: 100000,
      cashier: 'John',
      soldDate: '08/01/2025',
      dueDate: '22/01/2025',
    ),
    _CreditorItem(
      invoiceNo: 'INV-2025-004',
      customerName: 'Pham Thi D',
      phone: '0923456789',
      total: 560000,
      paid: 300000,
      balance: 260000,
      cashier: 'Jane',
      soldDate: '10/01/2025',
      dueDate: '25/01/2025',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_CreditorItem> get _filteredItems {
    final keyword = _searchController.text.trim().toLowerCase();
    return _items.where((item) {
      final status = _statusFor(item.dueDate);
      final matchKeyword =
          keyword.isEmpty ||
          item.invoiceNo.toLowerCase().contains(keyword) ||
          item.customerName.toLowerCase().contains(keyword) ||
          item.phone.contains(keyword);
      final matchFilter = _filter == 'all' || status.key == _filter;
      return matchKeyword && matchFilter;
    }).toList();
  }

  _CreditStatus _statusFor(String dueDate) {
    final parts = dueDate.split('/');
    if (parts.length != 3) {
      return const _CreditStatus(
        key: 'ontrack',
        label: 'On track',
        bgColor: Color(0xFFDCFCE7),
        textColor: Color(0xFF166534),
      );
    }
    final day = int.tryParse(parts[0]) ?? 1;
    final month = int.tryParse(parts[1]) ?? 1;
    final year = int.tryParse(parts[2]) ?? 2000;
    final due = DateTime(year, month, day);
    final now = DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);
    final diff = due.difference(nowDate).inDays;
    if (diff < 0) {
      return const _CreditStatus(
        key: 'overdue',
        label: 'Overdue',
        bgColor: Color(0xFFFEE2E2),
        textColor: Color(0xFF991B1B),
      );
    }
    if (diff <= 3) {
      return const _CreditStatus(
        key: 'dueSoon',
        label: 'Due soon',
        bgColor: Color(0xFFFFEDD5),
        textColor: Color(0xFF9A3412),
      );
    }
    return const _CreditStatus(
      key: 'ontrack',
      label: 'On track',
      bgColor: Color(0xFFDCFCE7),
      textColor: Color(0xFF166534),
    );
  }

  String _formatMoney(int value) {
    final raw = value.abs().toString();
    final chunks = <String>[];
    for (var i = raw.length; i > 0; i -= 3) {
      final start = (i - 3) < 0 ? 0 : i - 3;
      chunks.add(raw.substring(start, i));
    }
    final formatted = chunks.reversed.join(',');
    final sign = value < 0 ? '-' : '';
    return '$sign$formattedđ';
  }

  void _openDetail(_CreditorItem item) {
    final status = _statusFor(item.dueDate);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.55,
          maxChildSize: 0.96,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.invoiceNo,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _StatusPill(status: status),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _DetailBlock(
                    title: 'Customer',
                    children: [
                      _DetailRow(label: 'Name', value: item.customerName),
                      _DetailRow(label: 'Phone', value: item.phone),
                    ],
                  ),
                  _DetailBlock(
                    title: 'Payment',
                    children: [
                      _DetailRow(label: 'Total', value: _formatMoney(item.total)),
                      _DetailRow(label: 'Paid', value: _formatMoney(item.paid)),
                      _DetailRow(
                        label: 'Balance',
                        value: _formatMoney(item.balance),
                        valueColor: const Color(0xFFDC2626),
                      ),
                    ],
                  ),
                  _DetailBlock(
                    title: 'Invoice info',
                    children: [
                      _DetailRow(label: 'Cashier', value: item.cashier),
                      _DetailRow(label: 'Sold date', value: item.soldDate),
                      _DetailRow(label: 'Due date', value: item.dueDate),
                      _DetailRow(label: 'Role', value: widget.roleLabel),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Collect payment'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          DashboardHeader(
            fullName: widget.fullName,
            roleLabel: widget.roleLabel,
            currentTimeText: widget.currentTimeText,
            isCompact: widget.isCompact,
            title: 'Creditors',
            onProfileTap: widget.onProfileTap,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryCard(items: _items, formatMoney: _formatMoney),
                const SizedBox(height: 12),
                _SearchBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                _FilterChips(
                  selected: _filter,
                  onChanged: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: 10),
                if (items.isEmpty)
                  const _EmptyState()
                else
                  ...items.map(
                    (item) => _CreditorCard(
                      item: item,
                      status: _statusFor(item.dueDate),
                      formatMoney: _formatMoney,
                      onTap: () => _openDetail(item),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.items, required this.formatMoney});

  final List<_CreditorItem> items;
  final String Function(int value) formatMoney;

  @override
  Widget build(BuildContext context) {
    final totalBalance = items.fold<int>(0, (sum, item) => sum + item.balance);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Credit summary',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryValue(
                  label: 'Total invoices',
                  value: '${items.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryValue(
                  label: 'Outstanding',
                  value: formatMoney(totalBalance),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _CreditorCard extends StatelessWidget {
  const _CreditorCard({
    required this.item,
    required this.status,
    required this.formatMoney,
    required this.onTap,
  });

  final _CreditorItem item;
  final _CreditStatus status;
  final String Function(int value) formatMoney;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8EAED)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.invoiceNo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  _StatusPill(status: status),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                ],
              ),
              const SizedBox(height: 6),
              Text(item.customerName),
              const SizedBox(height: 2),
              Text(
                item.phone,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),
              Text(
                'Balance: ${formatMoney(item.balance)}',
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Due: ${item.dueDate}  -  Cashier: ${item.cashier}',
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditorItem {
  const _CreditorItem({
    required this.invoiceNo,
    required this.customerName,
    required this.phone,
    required this.total,
    required this.paid,
    required this.balance,
    required this.cashier,
    required this.soldDate,
    required this.dueDate,
  });

  final String invoiceNo;
  final String customerName;
  final String phone;
  final int total;
  final int paid;
  final int balance;
  final String cashier;
  final String soldDate;
  final String dueDate;
}

class _CreditStatus {
  const _CreditStatus({
    required this.key,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  final String key;
  final String label;
  final Color bgColor;
  final Color textColor;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final _CreditStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search invoice, customer, phone...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _FilterChipItem(
          label: 'All',
          active: selected == 'all',
          onTap: () => onChanged('all'),
        ),
        _FilterChipItem(
          label: 'Overdue',
          active: selected == 'overdue',
          onTap: () => onChanged('overdue'),
        ),
        _FilterChipItem(
          label: 'Due soon',
          active: selected == 'dueSoon',
          onTap: () => onChanged('dueSoon'),
        ),
        _FilterChipItem(
          label: 'On track',
          active: selected == 'ontrack',
          onTap: () => onChanged('ontrack'),
        ),
      ],
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? const Color(0xFFDBEAFE) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? const Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: Text(
          'No invoices found.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
