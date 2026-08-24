import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/presentation/widgets/dashboard_header.dart';
import 'package:go_router/go_router.dart';
import 'package:supermarket_manager_system/data/services/supplier_api_service.dart';
import 'package:supermarket_manager_system/domain/models/supplier_list_item.dart';

class SuppliersContent extends StatefulWidget {
  const SuppliersContent({
    super.key,
    required this.fullName,
    required this.isCompact,
    required this.currentTimeText,
    required this.onProfileTap,
    this.basePath = 'admin',
    this.onSupplierDetailTap,
  });

  final String fullName;
  final bool isCompact;
  final String currentTimeText;
  final VoidCallback onProfileTap;
  final String basePath;
  final ValueChanged<int>? onSupplierDetailTap;

  @override
  State<SuppliersContent> createState() => _SuppliersContentState();
}

class _SuppliersContentState extends State<SuppliersContent> {
  final _supplierApiService = SupplierApiService();
  late Future<List<SupplierListItem>> _suppliersFuture;

  int? _selectedSupplierId;
  Future<SupplierListItem>? _selectedSupplierFuture;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _suppliersFuture = _supplierApiService.getSuppliers();
  }

  void _reloadSuppliers() {
    setState(() {
      _suppliersFuture = _supplierApiService.getSuppliers();
    });
  }

  void _openSupplierDetail(SupplierListItem supplier) {
    setState(() {
      _selectedSupplierId = supplier.id;
      _selectedSupplierFuture = _supplierApiService.getSupplierById(supplier.id);
    });
  }

  void _closeSupplierDetail() {
    setState(() {
      _selectedSupplierId = null;
      _selectedSupplierFuture = null;
      _isUpdatingStatus = false;
    });
    _reloadSuppliers();
  }

  Future<void> _openAddSupplierDialog() async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _AddSupplierDialog(supplierApiService: _supplierApiService),
    );

    if (!mounted) {
      return;
    }

    if (created == true) {
      _reloadSuppliers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier created successfully')),
      );
    }
  }

  Future<void> _openDeleteSupplierPopup(SupplierListItem supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text(
          'Are you sure you want to delete "${supplier.supplierName.isEmpty ? "this supplier" : supplier.supplierName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      await _supplierApiService.deleteSupplier(supplier.id);
      if (!mounted) return;
      if (_selectedSupplierId == supplier.id) {
        _closeSupplierDetail();
      } else {
        _reloadSuppliers();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openUpdateSupplierDialog(SupplierListItem supplier) async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UpdateSupplierDialog(
        supplierApiService: _supplierApiService,
        supplier: supplier,
      ),
    );

    if (!mounted) {
      return;
    }

    if (updated == true) {
      _reloadSuppliers();
      if (_selectedSupplierId == supplier.id) {
        _selectedSupplierFuture =
            _supplierApiService.getSupplierById(supplier.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier updated successfully')),
      );
    }
  }

  Future<void> _setSupplierStatus(SupplierListItem supplier, String newStatus) async {
    setState(() => _isUpdatingStatus = true);
    try {
      await _supplierApiService.updateSupplier(
        id: supplier.id,
        supplierName: supplier.supplierName,
        companyName: supplier.companyName.trim().isEmpty ? null : supplier.companyName,
        email: supplier.email.trim().isEmpty ? null : supplier.email,
        phone: supplier.phone.trim().isEmpty ? null : supplier.phone,
        address: supplier.address.trim().isEmpty ? null : supplier.address,
        status: newStatus,
      );
      if (!mounted) return;
      if (_selectedSupplierId == supplier.id) {
        _selectedSupplierFuture =
            _supplierApiService.getSupplierById(supplier.id);
      }
      _reloadSuppliers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Supplier status updated to ${newStatus.toUpperCase()}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          _SuppliersHeader(
            fullName: widget.fullName,
            isCompact: widget.isCompact,
            currentTimeText: widget.currentTimeText,
            onProfileTap: widget.onProfileTap,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedSupplierId == null
                            ? 'List Supplier'
                            : 'Supplier Detail',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_selectedSupplierId == null)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                            ),
                          ),
                          child: TextButton(
                            onPressed: _openAddSupplierDialog,
                            child: const Text(
                              '+ Add Supplier',
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
                    child: _selectedSupplierId == null
                        ? FutureBuilder<List<SupplierListItem>>(
                            future: _suppliersFuture,
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
                                        'Cannot load suppliers: ${snapshot.error}',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: _reloadSuppliers,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final suppliers = snapshot.data ?? [];

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE8EAED),
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: ListView.separated(
                                  itemCount: suppliers.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, idx) {
                                    final s = suppliers[idx];
                                    final normalizedStatus = s.status.toLowerCase();
                                    final isActive = normalizedStatus == 'active';

                                    return InkWell(
                                      onTap: () => _openSupplierDetail(s),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: const Color(0xFFE8EAED),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    s.supplierName.isEmpty
                                                        ? '—'
                                                        : s.supplierName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    s.companyName.isEmpty
                                                        ? 'Company: —'
                                                        : 'Company: ${s.companyName}',
                                                    style: TextStyle(
                                                      color:
                                                          const Color(0xFF6B7280),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    s.email.isEmpty ? 'Email: —' : s.email,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF374151),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    s.phone.isEmpty ? 'Phone: —' : s.phone,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF374151),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                _StatusChip(status: s.status),
                                                const SizedBox(height: 10),
                                                Icon(
                                                  isActive
                                                      ? Icons
                                                          .keyboard_arrow_right_rounded
                                                      : Icons.arrow_right_alt_rounded,
                                                  size: 20,
                                                  color: const Color(0xFF2E7D32),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          )
                        : FutureBuilder<SupplierListItem>(
                            future: _selectedSupplierFuture,
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
                                        'Cannot load supplier detail: ${snapshot.error}',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: _closeSupplierDetail,
                                        child: const Text('Back'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final s = snapshot.data!;
                              final normalizedStatus = s.status.toLowerCase();
                              final canDelete = normalizedStatus != 'deactive';

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE8EAED),
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: _closeSupplierDetail,
                                              icon: const Icon(Icons.arrow_back),
                                              tooltip: 'Back',
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              s.supplierName.isEmpty ? '—' : s.supplierName,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        _StatusChip(status: s.status),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Divider(color: Color(0xFFE8EAED), thickness: 1),
                                    const SizedBox(height: 14),
                                    _DetailLine(label: 'Company', value: s.companyName),
                                    _DetailLine(label: 'Email', value: s.email),
                                    _DetailLine(label: 'Phone', value: s.phone),
                                    _DetailLine(label: 'Address', value: s.address),
                                    if (s.createdAt != null && s.createdAt!.isNotEmpty)
                                      _DetailLine(label: 'Created', value: s.createdAt!),
                                    const SizedBox(height: 18),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () =>
                                              _openUpdateSupplierDialog(s),
                                          icon: const Icon(Icons.edit_outlined),
                                          label: const Text('Edit'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFF2E7D32),
                                            side: const BorderSide(
                                              color: Color(0xFF2E7D32),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 10,
                                            ),
                                          ),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed: _isUpdatingStatus
                                              ? null
                                              : () {
                                                  final targetActive = normalizedStatus != 'active';
                                                  _setSupplierStatus(
                                                    s,
                                                    targetActive ? 'active' : 'deactive',
                                                  );
                                                },
                                          icon: Icon(
                                            normalizedStatus == 'active'
                                                ? Icons.toggle_off_outlined
                                                : Icons.toggle_on_outlined,
                                          ),
                                          label: Text(
                                            normalizedStatus == 'active'
                                                ? 'Set Deactive'
                                                : 'Set Active',
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFF2E7D32),
                                            side: const BorderSide(
                                              color: Color(0xFF2E7D32),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 10,
                                            ),
                                          ),
                                        ),
                                        if (canDelete)
                                          OutlinedButton.icon(
                                            onPressed: () =>
                                                _openDeleteSupplierPopup(s),
                                            icon: const Icon(Icons.delete_outline),
                                            label: const Text('Delete'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.red,
                                              side: const BorderSide(color: Colors.red),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 10,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
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

  // Simple detail line for inline detail view.
  // ignore: unused_element
  DataRow _buildRow(int index, SupplierListItem supplier) {
    final normalizedStatus = supplier.status.toLowerCase();
    final canDelete = normalizedStatus != 'deactive';

    return DataRow(
      cells: [
        DataCell(SizedBox(width: 28, child: Text(index.toString()))),
        DataCell(
          SizedBox(
            width: 100,
            child: Text(
              supplier.supplierName.isEmpty ? '-' : supplier.supplierName,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 80,
            child: Text(
              supplier.companyName.isEmpty ? '-' : supplier.companyName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Text(
              supplier.email.isEmpty ? '-' : supplier.email,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 70,
            child: Text(
              supplier.phone.isEmpty ? '-' : supplier.phone,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 80,
            child: Text(
              supplier.address.isEmpty ? '-' : supplier.address,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        DataCell(
          SizedBox(width: 70, child: _StatusChip(status: supplier.status)),
        ),
        DataCell(
          SizedBox(
            width: 220,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    final id = supplier.id;
                    if (widget.onSupplierDetailTap != null) {
                      widget.onSupplierDetailTap!(id);
                      return;
                    }
                    // Fallback: route navigation (when not embedded in dashboard)
                    context.push('/${widget.basePath}/supplier-detail/$id');
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    foregroundColor: const Color(0xFF2E7D32),
                    side: const BorderSide(color: Color(0xFF2E7D32)),
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: () => _openUpdateSupplierDialog(supplier),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    foregroundColor: const Color(0xFF2E7D32),
                    side: const BorderSide(color: Color(0xFF2E7D32)),
                  ),
                ),
                if (canDelete) const SizedBox(width: 6),
                if (canDelete)
                  OutlinedButton.icon(
                    onPressed: () => _openDeleteSupplierPopup(supplier),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final v = value.trim().isEmpty ? '—' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateSupplierDialog extends StatefulWidget {
  const _UpdateSupplierDialog({
    required this.supplierApiService,
    required this.supplier,
  });

  final SupplierApiService supplierApiService;
  final SupplierListItem supplier;

  @override
  State<_UpdateSupplierDialog> createState() => _UpdateSupplierDialogState();
}

class _UpdateSupplierDialogState extends State<_UpdateSupplierDialog> {
  late final TextEditingController _supplierNameController;
  late final TextEditingController _companyNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  late String _status;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _supplierNameController = TextEditingController(text: s.supplierName);
    _companyNameController = TextEditingController(text: s.companyName);
    _emailController = TextEditingController(text: s.email);
    _phoneController = TextEditingController(text: s.phone);
    _addressController = TextEditingController(text: s.address);
    _status = s.status.isEmpty ? 'active' : s.status;
  }

  @override
  void dispose() {
    _supplierNameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formKey = _formKey.currentState;
    if (formKey == null || !formKey.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await widget.supplierApiService.updateSupplier(
        id: widget.supplier.id,
        supplierName: _supplierNameController.text.trim(),
        companyName: _companyNameController.text.trim().isEmpty
            ? null
            : _companyNameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        status: _status,
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      final errorMessage = error.toString().replaceFirst('Exception: ', '');
      setState(() {
        _errorText = errorMessage;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Update Supplier',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _supplierNameController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Supplier name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _companyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'deactive',
                        child: Text('Deactive'),
                      ),
                    ],
                    onChanged: _isSubmitting
                        ? null
                        : (v) => setState(() => _status = v ?? 'active'),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Update'),
                      ),
                    ],
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

class _SuppliersHeader extends StatelessWidget {
  const _SuppliersHeader({
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isActive = normalized == 'active';
    final bg = isActive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
    final fg = isActive ? const Color(0xFF065F46) : const Color(0xFF991B1B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: bg,
      ),
      child: Text(
        status.isEmpty ? '-' : status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _AddSupplierDialog extends StatefulWidget {
  const _AddSupplierDialog({required this.supplierApiService});

  final SupplierApiService supplierApiService;

  @override
  State<_AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends State<_AddSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  final _supplierNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _status = 'active';
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _supplierNameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await widget.supplierApiService.createSupplier(
        supplierName: _supplierNameController.text.trim(),
        companyName: _companyNameController.text.trim().isEmpty
            ? null
            : _companyNameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        status: _status,
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      final errorMessage = error.toString().replaceFirst('Exception: ', '');
      setState(() {
        _errorText = errorMessage;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add Supplier',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _supplierNameController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Supplier name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _companyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'deactive',
                        child: Text('Deactive'),
                      ),
                    ],
                    onChanged: _isSubmitting
                        ? null
                        : (v) => setState(() => _status = v ?? 'active'),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ],
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
