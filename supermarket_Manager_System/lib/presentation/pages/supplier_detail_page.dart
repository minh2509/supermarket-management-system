import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supermarket_manager_system/data/services/supplier_api_service.dart';
import 'package:supermarket_manager_system/domain/models/supplier_list_item.dart';

class SupplierDetailPage extends StatefulWidget {
  const SupplierDetailPage({
    super.key,
    required this.supplierId,
    required this.basePath,
    this.onBack,
  });

  final int supplierId;
  final String basePath;
  final VoidCallback? onBack;

  @override
  State<SupplierDetailPage> createState() => _SupplierDetailPageState();
}

class _SupplierDetailPageState extends State<SupplierDetailPage> {
  final _api = SupplierApiService();
  late Future<SupplierListItem> _supplierFuture;

  @override
  void initState() {
    super.initState();
    _supplierFuture = _api.getSupplierById(widget.supplierId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
              return;
            }
            context.pop();
          },
        ),
        title: const Text('Supplier Detail'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<SupplierListItem>(
        future: _supplierFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                        return;
                      }
                      context.pop();
                    },
                    child: const Text('Back to list'),
                  ),
                ],
              ),
            );
          }

          final s = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          s.supplierName.isEmpty ? '—' : s.supplierName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                          label: 'Company',
                          value: s.companyName.isEmpty ? '—' : s.companyName,
                        ),
                        _DetailRow(
                          label: 'Email',
                          value: s.email.isEmpty ? '—' : s.email,
                        ),
                        _DetailRow(
                          label: 'Phone',
                          value: s.phone.isEmpty ? '—' : s.phone,
                        ),
                        _DetailRow(
                          label: 'Address',
                          value: s.address.isEmpty ? '—' : s.address,
                        ),
                        _DetailRow(
                          label: 'Status',
                          value: s.status.isEmpty ? '—' : s.status,
                        ),
                        if (s.createdAt != null && s.createdAt!.isNotEmpty)
                          _DetailRow(
                            label: 'Created at',
                            value: s.createdAt!,
                          ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: () {
                            if (widget.onBack != null) {
                              widget.onBack!();
                              return;
                            }
                            context.pop();
                          },
                          icon: const Icon(Icons.list),
                          label: const Text('Back to list'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2E7D32),
                            side: const BorderSide(color: Color(0xFF2E7D32)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
