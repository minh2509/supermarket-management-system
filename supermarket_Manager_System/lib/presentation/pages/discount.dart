import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/presentation/widgets/dashboard_header.dart';
import 'package:supermarket_manager_system/data/services/discount_api_service.dart';
import 'package:supermarket_manager_system/domain/models/discount.dart';

class DiscountsContent extends StatefulWidget {
  const DiscountsContent({
    super.key,
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
  State<DiscountsContent> createState() => _DiscountsContentState();
}

class _DiscountsContentState extends State<DiscountsContent> {
  final _discountApiService = DiscountApiService();
  late Future<List<Discount>> _discountsFuture;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _reloadDiscounts();
  }

  void _reloadDiscounts() {
    setState(() {
      _discountsFuture = _discountApiService.getDiscounts();
    });
  }

  Future<void> _openAddDiscountDialog() async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _AddEditDiscountDialog(discountApiService: _discountApiService),
    );

    if (mounted && created == true) {
      _reloadDiscounts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discount created successfully')),
      );
    }
  }

  Future<void> _openEditDiscountDialog(Discount discount) async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddEditDiscountDialog(
        discountApiService: _discountApiService,
        discount: discount,
      ),
    );

    if (mounted && updated == true) {
      _reloadDiscounts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discount updated successfully')),
      );
    }
  }

  Future<void> _deleteDiscount(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this discount?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _discountApiService.deleteDiscount(id);
        _reloadDiscounts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Discount deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting discount: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagePadding = widget.isCompact ? 16.0 : 24.0;
    return Container(
      color: const Color(0xFFF4F7FC),
      child: Column(
        children: [
          _DiscountsHeader(
            fullName: widget.fullName,
            isCompact: widget.isCompact,
            currentTimeText: widget.currentTimeText,
            onProfileTap: widget.onProfileTap,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.isCompact)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Discount',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _openAddDiscountDialog,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Discount'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Discount',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1D21),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFF2563EB),
                          ),
                          child: TextButton.icon(
                            onPressed: _openAddDiscountDialog,
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Add Discount',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<Discount>>(
                      future: _discountsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        final discounts = snapshot.data ?? [];
                        if (discounts.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFE3EAF6),
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_offer_outlined,
                                  size: 42,
                                  color: Color(0xFF94A3B8),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'No discounts found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (widget.isCompact) {
                          return ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: discounts.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final d = discounts[index];
                              return _buildMobileDiscountCard(d, index + 1);
                            },
                          );
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE3EAF6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: const WidgetStatePropertyAll(
                                    Color(0xFFF7F8FA),
                                  ),
                                  headingTextStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4A5568),
                                    fontSize: 12,
                                  ),
                                  columns: const [
                                    DataColumn(label: Text('S/N')),
                                    DataColumn(label: Text('DISCOUNT NAME')),
                                    DataColumn(label: Text('DISCOUNT %')),
                                    DataColumn(label: Text('MIN ORDER AMOUNT')),
                                    DataColumn(label: Text('START DATE')),
                                    DataColumn(label: Text('END DATE')),
                                    DataColumn(label: Text('ACTION')),
                                  ],
                                  rows: discounts.asMap().entries.map((entry) {
                                    final index = entry.key + 1;
                                    final d = entry.value;
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(index.toString())),
                                        DataCell(Text(d.name)),
                                        DataCell(Text('${d.percent}%')),
                                        DataCell(
                                          Text(
                                            '${d.minOrderAmount.toStringAsFixed(0)}đ',
                                          ),
                                        ),
                                        DataCell(
                                          Text(_formatDate(d.startDate)),
                                        ),
                                        DataCell(Text(_formatDate(d.endDate))),
                                        DataCell(
                                          Row(
                                            children: [
                                              _ActionButton(
                                                label: 'Edit',
                                                color: const Color(0xFFEFF4FF),
                                                foregroundColor: const Color(
                                                  0xFF1E40AF,
                                                ),
                                                onTap: () =>
                                                    _openEditDiscountDialog(d),
                                              ),
                                              const SizedBox(width: 8),
                                              _ActionButton(
                                                label: 'Delete',
                                                color: const Color(0xFFDC2626),
                                                onTap: () =>
                                                    _deleteDiscount(d.id),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatMoney(double value) {
    final formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$formattedđ';
  }

  Widget _buildMobileDiscountCard(Discount d, int index) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7ECF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10213A63),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '#$index  ${d.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DiscountMetricChip(label: 'Percent', value: '${d.percent}%'),
              _DiscountMetricChip(
                label: 'Min Order',
                value: _formatMoney(d.minOrderAmount),
              ),
              _DiscountMetricChip(
                label: 'Start',
                value: _formatDate(d.startDate),
              ),
              _DiscountMetricChip(label: 'End', value: _formatDate(d.endDate)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Edit',
                  color: const Color(0xFFEFF4FF),
                  foregroundColor: const Color(0xFF1E40AF),
                  onTap: () => _openEditDiscountDialog(d),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: 'Delete',
                  color: const Color(0xFFDC2626),
                  onTap: () => _deleteDiscount(d.id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiscountsHeader extends StatelessWidget {
  const _DiscountsHeader({
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
    return DashboardHeader(
      fullName: fullName,
      roleLabel: 'Manager',
      currentTimeText: currentTimeText,
      isCompact: isCompact,
      onProfileTap: onProfileTap,
      timeChipColor: const Color(0xFF2E7D32),
      avatarColor: const Color(0xFF2E7D32),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    this.color,
    this.foregroundColor,
    required this.onTap,
  });

  final String label;
  final Color? color;
  final Color? foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: foregroundColor ?? Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DiscountMetricChip extends StatelessWidget {
  const _DiscountMetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EBF8)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF111827)),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddEditDiscountDialog extends StatefulWidget {
  const _AddEditDiscountDialog({
    required this.discountApiService,
    this.discount,
  });

  final DiscountApiService discountApiService;
  final Discount? discount;

  @override
  State<_AddEditDiscountDialog> createState() => _AddEditDiscountDialogState();
}

class _AddEditDiscountDialogState extends State<_AddEditDiscountDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _percentController;
  late TextEditingController _minOrderController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.discount?.name ?? '');
    _percentController = TextEditingController(
      text: widget.discount?.percent.toString() ?? '',
    );
    _minOrderController = TextEditingController(
      text: widget.discount?.minOrderAmount.toString() ?? '',
    );
    _startDateController = TextEditingController(
      text: widget.discount != null
          ? _formatDate(widget.discount!.startDate)
          : '',
    );
    _endDateController = TextEditingController(
      text: widget.discount != null
          ? _formatDate(widget.discount!.endDate)
          : '',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = _formatDate(picked);
      });
    }
  }

  DateTime _parseDate(String text) {
    final parts = text.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final newDiscount = Discount(
        id: widget.discount?.id ?? 0,
        name: _nameController.text.trim(),
        percent: double.parse(_percentController.text),
        minOrderAmount: double.parse(_minOrderController.text),
        startDate: _parseDate(_startDateController.text),
        endDate: _parseDate(_endDateController.text),
      );

      if (newDiscount.startDate.isAfter(newDiscount.endDate)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Start date must be before or equal to End date'),
            ),
          );
        }
        return;
      }

      if (widget.discount == null) {
        await widget.discountApiService.createDiscount(newDiscount);
      } else {
        await widget.discountApiService.updateDiscount(
          widget.discount!.id,
          newDiscount,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        String displayError = errorMsg;
        try {
          final decoded = jsonDecode(errorMsg);
          if (decoded is Map) {
            displayError = decoded.values.first.toString();
          }
        } catch (_) {}
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $displayError')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height - mediaQuery.viewInsets.bottom - 48;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: mediaQuery.size.width < 600 ? 16 : 40,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: availableHeight < 280 ? 280 : availableHeight,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(mediaQuery.size.width < 600 ? 18 : 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.discount == null
                          ? 'Add Discount'
                          : 'Edit Discount',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                _buildTextField(
                  'Discount Name',
                  _nameController,
                  hint: 'e.g. Holiday Special',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Discount %',
                  _percentController,
                  hint: 'e.g. 5',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Min Order Amount (đ)',
                  _minOrderController,
                  hint: 'e.g. 500000',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildDateField('Start Date', _startDateController),
                const SizedBox(height: 12),
                _buildDateField('End Date', _endDateController),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.discount == null ? 'Submit' : 'Update',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            if (label == 'Discount Name') {
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
            }
            if (label.contains('%')) {
              final val = double.tryParse(value);
              if (val == null) return 'Invalid number';
              if (val < 0 || val > 100) {
                return 'Percent must be between 0 and 100';
              }
            }
            if (label.contains('Amount')) {
              final val = double.tryParse(value);
              if (val == null) return 'Invalid number';
              if (val < 0) return 'Amount cannot be negative';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(controller),
          decoration: InputDecoration(
            hintText: 'DD/MM/YYYY',
            prefixIcon: const Icon(Icons.calendar_today, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            if (label == 'End Date' && _startDateController.text.isNotEmpty) {
              try {
                final start = _parseDate(_startDateController.text);
                final end = _parseDate(value);
                if (end.isBefore(start)) {
                  return 'End date cannot be before start date';
                }
              } catch (_) {}
            }
            return null;
          },
        ),
      ],
    );
  }
}
