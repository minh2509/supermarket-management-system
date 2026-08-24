import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/domain/models/product_list_item.dart';

String formatVndPrice(double amount) {
  final raw = amount.round().abs().toString();
  final buf = StringBuffer();
  final len = raw.length;
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) {
      buf.write('.');
    }
    buf.write(raw[i]);
  }
  final sign = amount < 0 ? '-' : '';
  return '$sign${buf.toString()}đ';
}

/// Modal overlay: product list like cashier HTML search results.
/// Returns the selected product, or null if closed without selection.
Future<ProductListItem?> showCashierProductSearchDialog(
  BuildContext context, {
  required List<ProductListItem> products,
  String title = 'Search results',
}) {
  return showDialog<ProductListItem>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 1100,
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          child: _CashierProductSearchContent(
            products: products,
            title: title,
          ),
        ),
      );
    },
  );
}

class _CashierProductSearchContent extends StatefulWidget {
  const _CashierProductSearchContent({
    required this.products,
    required this.title,
  });

  final List<ProductListItem> products;
  final String title;

  @override
  State<_CashierProductSearchContent> createState() =>
      _CashierProductSearchContentState();
}

class _CashierProductSearchContentState
    extends State<_CashierProductSearchContent> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<ProductListItem> get _filteredProducts {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return widget.products;
    }
    return widget.products.where((p) {
      return p.productName.toLowerCase().contains(q) ||
          p.barcode.toLowerCase().contains(q) ||
          p.categoryName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      elevation: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE8EAED)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _query.trim().isEmpty
                        ? widget.title
                        : 'Filtered (${filtered.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1D21),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _queryController,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search by name, barcode, or category...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _queryController.clear();
                          setState(() => _query = '');
                        },
                      ),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFF2E7D32), width: 1),
                ),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No products match your search.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: const WidgetStatePropertyAll(
                            Color(0xFFF1F5F9),
                          ),
                          dataRowMinHeight: 48,
                          dataRowMaxHeight: 56,
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(
                              label: Text(
                                'S/N',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'BARCODE',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'PRODUCTS',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'CATEGORY',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'EXPIRE',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'PRICE',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'IN STOCK',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                          rows: filtered.asMap().entries.map((entry) {
                            final i = entry.key;
                            final p = entry.value;
                            return DataRow(
                              onSelectChanged: (_) {
                                Navigator.of(context).pop(p);
                              },
                              cells: [
                                DataCell(Text('${i + 1}')),
                                DataCell(
                                  Text(
                                    p.barcode,
                                    style: const TextStyle(
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    p.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DataCell(Text(p.categoryName)),
                                DataCell(Text(p.expiryDate)),
                                DataCell(
                                  Text(
                                    formatVndPrice(p.sellingPrice),
                                  ),
                                ),
                                DataCell(Text('${p.inStock}')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
          if (filtered.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                'Tap a row to add the product to the cart.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
