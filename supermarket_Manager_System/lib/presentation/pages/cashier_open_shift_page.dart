import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supermarket_manager_system/data/services/shift_api_service.dart';
import 'package:supermarket_manager_system/domain/models/cashier_shift.dart';
import 'package:supermarket_manager_system/presentation/pages/cashier_shift_views.dart';
import 'package:supermarket_manager_system/presentation/theme/app_theme.dart';
import 'package:supermarket_manager_system/utils/app_session.dart';

class CashierOpenShiftPage extends StatefulWidget {
  const CashierOpenShiftPage({super.key, required this.fullName});

  final String fullName;

  @override
  State<CashierOpenShiftPage> createState() => _CashierOpenShiftPageState();
}

class _CashierOpenShiftPageState extends State<CashierOpenShiftPage> {
  final TextEditingController _initialCashController = TextEditingController();
  final ShiftApiService _shiftApiService = ShiftApiService();
  late final DateTime _loginTime;
  CashierShift? _activeShift;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loginTime = DateTime.now();
    _loadCurrentShift();
  }

  @override
  void dispose() {
    _initialCashController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_twoDigits(dateTime.day)}/${_twoDigits(dateTime.month)}/${dateTime.year} '
        '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  Future<void> _loadCurrentShift() async {
    final userId = AppSession.instance.userId;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'Your login session is no longer available.';
      });
      return;
    }
    try {
      final shift = await _shiftApiService.getCurrentShift(userId);
      if (!mounted) return;
      setState(() {
        _activeShift = shift;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _onConfirmStartShift() async {
    final raw = _initialCashController.text.trim().replaceAll(',', '');
    final amount = double.tryParse(raw);
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid initial cash amount.'),
        ),
      );
      return;
    }
    final userId = AppSession.instance.userId;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in again.')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _shiftApiService.openShift(userId: userId, initialCash: amount);
      if (!mounted) return;
      context.go('/cashier/barcode-scanner');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_activeShift != null) {
      return _buildActiveShiftHome(_activeShift!);
    }
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outline),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    blurRadius: 32,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start your shift',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Confirm the drawer amount before you start selling.',
                          style: TextStyle(
                            color: Color(0xFFD8F1E3),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_loadError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFED7AA),
                              ),
                            ),
                            child: Text(
                              _loadError!,
                              style: const TextStyle(color: Color(0xFF9A3412)),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                        const _OpenShiftLabel('Employee name'),
                        const SizedBox(height: 8),
                        _ReadOnlyField(
                          text: widget.fullName.isNotEmpty
                              ? widget.fullName
                              : 'Cashier',
                        ),
                        const SizedBox(height: 20),
                        const _OpenShiftLabel('Login time'),
                        const SizedBox(height: 8),
                        _ReadOnlyField(text: _formatDateTime(_loginTime)),
                        const SizedBox(height: 20),
                        const _OpenShiftLabel('Opening cash amount'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _initialCashController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0',
                            prefixIcon: const Icon(Icons.payments_outlined),
                            suffixText: 'VND',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Total cash in drawer at the start of your shift.',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      border: Border(top: BorderSide(color: AppColors.outline)),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _onConfirmStartShift,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Confirm & start shift',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveShiftHome(CashierShift shift) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.outline),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 30,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.storefront_rounded,
                    size: 52,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Your shift is open',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Started ${formatShiftDate(shift.openTime)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 22),
                  _HomeShiftRow(
                    label: 'Opening cash',
                    value: formatShiftMoney(shift.initialCash),
                  ),
                  _HomeShiftRow(
                    label: 'Current revenue',
                    value: formatShiftMoney(shift.revenue),
                  ),
                  _HomeShiftRow(label: 'Orders', value: '${shift.orderCount}'),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: () => context.go('/cashier/barcode-scanner'),
                    icon: const Icon(Icons.point_of_sale_rounded),
                    label: const Text('Go to POS'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/cashier/shift'),
                    icon: const Icon(Icons.info_outline_rounded),
                    label: const Text('View shift information'),
                  ),
                  TextButton.icon(
                    onPressed: () => context.go('/cashier/shifts/history'),
                    icon: const Icon(Icons.history_rounded),
                    label: const Text('View shift history'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeShiftRow extends StatelessWidget {
  const _HomeShiftRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
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

class _OpenShiftLabel extends StatelessWidget {
  const _OpenShiftLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF374151),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1A1D21),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
