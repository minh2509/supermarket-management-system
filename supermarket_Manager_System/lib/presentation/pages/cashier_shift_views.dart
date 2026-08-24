import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/shift_api_service.dart';
import 'package:supermarket_manager_system/domain/models/cashier_shift.dart';
import 'package:supermarket_manager_system/presentation/theme/app_theme.dart';

class CashierShiftInformationView extends StatefulWidget {
  const CashierShiftInformationView({
    super.key,
    required this.userId,
    required this.onGoToPos,
    required this.onCloseShift,
  });

  final int userId;
  final VoidCallback onGoToPos;
  final VoidCallback onCloseShift;

  @override
  State<CashierShiftInformationView> createState() =>
      _CashierShiftInformationViewState();
}

class _CashierShiftInformationViewState
    extends State<CashierShiftInformationView> {
  final _service = ShiftApiService();
  late Future<CashierShift?> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getCurrentShift(widget.userId);
  }

  void _reload() =>
      setState(() => _future = _service.getCurrentShift(widget.userId));

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF4F7FC),
      child: FutureBuilder<CashierShift?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ShiftMessage(
              icon: Icons.cloud_off_outlined,
              title: 'Cannot load shift information',
              message: _cleanError(snapshot.error),
              buttonLabel: 'Try again',
              onPressed: _reload,
            );
          }
          final shift = snapshot.data;
          if (shift == null) {
            return const _ShiftMessage(
              icon: Icons.schedule_outlined,
              title: 'No open shift',
              message: 'Return to the start screen to open a shift first.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Shift Information',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF17212B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your current shift totals update after every transaction.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 18),
              _ShiftStatusCard(shift: shift),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoColumns = constraints.maxWidth >= 700;
                  final width = twoColumns
                      ? (constraints.maxWidth - 12) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetricCard(
                        width: width,
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Opening cash',
                        value: formatShiftMoney(shift.initialCash),
                        color: const Color(0xFF2563EB),
                      ),
                      _MetricCard(
                        width: width,
                        icon: Icons.payments_outlined,
                        label: 'Cash sales',
                        value: formatShiftMoney(shift.cashRevenue),
                        color: const Color(0xFF16A34A),
                      ),
                      _MetricCard(
                        width: width,
                        icon: Icons.receipt_long_outlined,
                        label: 'Orders in this shift',
                        value: '${shift.orderCount}',
                        color: const Color(0xFF7C3AED),
                      ),
                      _MetricCard(
                        width: width,
                        icon: Icons.trending_up_rounded,
                        label: 'Total revenue',
                        value: formatShiftMoney(shift.revenue),
                        color: const Color(0xFFEA580C),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: widget.onGoToPos,
                    icon: const Icon(Icons.point_of_sale_rounded),
                    label: const Text('Continue selling'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Refresh totals'),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.onCloseShift,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB91C1C),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                    ),
                    icon: const Icon(Icons.lock_clock_outlined),
                    label: const Text('Close shift'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class CashierShiftHistoryView extends StatefulWidget {
  const CashierShiftHistoryView({super.key, required this.userId});

  final int userId;

  @override
  State<CashierShiftHistoryView> createState() =>
      _CashierShiftHistoryViewState();
}

class _CashierShiftHistoryViewState extends State<CashierShiftHistoryView> {
  final _service = ShiftApiService();
  late Future<List<CashierShift>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getShiftHistory(widget.userId);
  }

  void _reload() =>
      setState(() => _future = _service.getShiftHistory(widget.userId));

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF4F7FC),
      child: FutureBuilder<List<CashierShift>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ShiftMessage(
              icon: Icons.cloud_off_outlined,
              title: 'Cannot load shift history',
              message: _cleanError(snapshot.error),
              buttonLabel: 'Try again',
              onPressed: _reload,
            );
          }
          final shifts = snapshot.data ?? const [];
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: shifts.isEmpty ? 2 : shifts.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shift History',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF17212B),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Your latest 30 shifts and reconciliation results.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                );
              }
              if (shifts.isEmpty) {
                return const _ShiftMessage(
                  icon: Icons.history_rounded,
                  title: 'No shift history yet',
                  message: 'Closed shifts will appear here.',
                );
              }
              return _HistoryCard(shift: shifts[index - 1]);
            },
          );
        },
      ),
    );
  }
}

class CashierShiftSummaryDialog extends StatelessWidget {
  const CashierShiftSummaryDialog({super.key, required this.shift});

  final CashierShift shift;

  @override
  Widget build(BuildContext context) {
    final difference = shift.difference ?? 0;
    final differenceColor = difference == 0
        ? const Color(0xFF15803D)
        : difference < 0
        ? const Color(0xFFB91C1C)
        : const Color(0xFFB45309);
    final differenceLabel = difference == 0
        ? 'Balanced'
        : difference < 0
        ? 'Shortage'
        : 'Overage';

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.task_alt_rounded, color: Color(0xFF16A34A)),
          SizedBox(width: 10),
          Text('Shift closed'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SummaryRow(label: 'Orders', value: '${shift.orderCount}'),
              _SummaryRow(
                label: 'Revenue',
                value: formatShiftMoney(shift.revenue),
              ),
              _SummaryRow(
                label: 'Opening cash',
                value: formatShiftMoney(shift.initialCash),
              ),
              _SummaryRow(
                label: 'System cash',
                value: formatShiftMoney(shift.systemCashEnd),
              ),
              _SummaryRow(
                label: 'Actual cash',
                value: formatShiftMoney(shift.totalCashEnd ?? 0),
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      differenceLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: differenceColor,
                      ),
                    ),
                  ),
                  Text(
                    formatShiftMoney(difference),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: differenceColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Finish'),
        ),
      ],
    );
  }
}

class _ShiftStatusCard extends StatelessWidget {
  const _ShiftStatusCard({required this.shift});

  final CashierShift shift;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        spacing: 28,
        runSpacing: 12,
        children: [
          _StatusValue(label: 'Employee', value: shift.employeeName),
          _StatusValue(label: 'Sales point', value: shift.salesPoint),
          _StatusValue(
            label: 'Started',
            value: formatShiftDate(shift.openTime),
          ),
          const _StatusValue(label: 'Status', value: 'OPEN'),
        ],
      ),
    );
  }
}

class _StatusValue extends StatelessWidget {
  const _StatusValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFBDE3CE))),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.shift});

  final CashierShift shift;

  @override
  Widget build(BuildContext context) {
    final difference = shift.difference;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatShiftDate(shift.openTime),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Chip(
                label: Text(shift.status),
                backgroundColor: shift.isOpen
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFE2E8F0),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 22,
            runSpacing: 8,
            children: [
              Text('${shift.orderCount} orders'),
              Text('Revenue: ${formatShiftMoney(shift.revenue)}'),
              Text('Actual: ${formatShiftMoney(shift.totalCashEnd ?? 0)}'),
              Text(
                difference == null
                    ? 'Difference: —'
                    : 'Difference: ${formatShiftMoney(difference)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ShiftMessage extends StatelessWidget {
  const _ShiftMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onPressed, child: Text(buttonLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

String formatShiftMoney(double value) {
  final negative = value < 0;
  final digits = value.abs().round().toString();
  final formatted = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return "${negative ? '-' : ''}$formatted\u20AB";
}

String formatShiftDate(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}/${value.year} '
      '${two(value.hour)}:${two(value.minute)}';
}

String _cleanError(Object? error) {
  return error.toString().replaceFirst('Exception: ', '');
}
