import 'package:excel/excel.dart' hide Border, TextSpan;
import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/product_api_service.dart';
import 'package:supermarket_manager_system/domain/models/create_product_request.dart';
import 'package:supermarket_manager_system/utils/excel_picker.dart';
import 'package:supermarket_manager_system/utils/excel_saver.dart';

/// Shows the bulk product import dialog.
/// Returns true if at least one product was imported successfully.
Future<bool?> showImportProductsDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ImportProductsDialog(),
  );
}

const _templateHeaders = [
  'Barcode',
  'Product Name',
  'Product Batch',
  'Description',
  'Category',
  'Supplier',
  'Cost Price',
  'Selling Price',
  'Cartons',
  'In Stock',
  'MFT Date (yyyy-mm-dd)',
  'Expiry Date (yyyy-mm-dd)',
];

class _ImportProductsDialog extends StatefulWidget {
  const _ImportProductsDialog();

  @override
  State<_ImportProductsDialog> createState() => _ImportProductsDialogState();
}

class _ImportProductsDialogState extends State<_ImportProductsDialog> {
  final _productApiService = ProductApiService();

  bool _busy = false;
  String? _progressText;
  int _importedCount = 0;
  List<String> _errors = [];
  bool _finished = false;

  Future<void> _downloadTemplate() async {
    setState(() => _busy = true);
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Products'];
      excel.delete('Sheet1');
      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#F1F5F9'),
      );
      sheet.appendRow([for (final h in _templateHeaders) TextCellValue(h)]);
      for (var col = 0; col < _templateHeaders.length; col++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
            .cellStyle = headerStyle;
      }
      sheet.appendRow([
        TextCellValue('8930000000099'),
        TextCellValue('Example Product 500g'),
        TextCellValue('BATCH-001'),
        TextCellValue('Optional description'),
        TextCellValue('Beverages'),
        TextCellValue('Example Supplier Co.'),
        DoubleCellValue(8000),
        DoubleCellValue(10000),
        IntCellValue(10),
        IntCellValue(100),
        TextCellValue('2026-01-01'),
        TextCellValue('2027-01-01'),
      ]);
      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('Failed to create the template file.');
      }
      final path = await saveExcelFile(bytes, 'product_import_template.xlsx');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            path == null
                ? 'Template downloaded.'
                : 'Template saved: $path',
          ),
          backgroundColor: const Color(0xFF2E7D32),
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
      if (mounted) setState(() => _busy = false);
    }
  }

  String _normalizeHeader(String raw) =>
      raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  String _cellText(Data? cell) {
    final v = cell?.value;
    if (v == null) return '';
    if (v is DateCellValue) return _fmtDate(v.asDateTimeLocal());
    if (v is DateTimeCellValue) return _fmtDate(v.asDateTimeLocal());
    if (v is DoubleCellValue) {
      final d = v.value;
      return d == d.roundToDouble() ? d.toInt().toString() : d.toString();
    }
    return v.toString().trim();
  }

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String? _parseDate(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    // yyyy-mm-dd (possibly with time suffix from Excel date cells)
    final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(text);
    if (iso != null) {
      return _fmtDate(
        DateTime(
          int.parse(iso.group(1)!),
          int.parse(iso.group(2)!),
          int.parse(iso.group(3)!),
        ),
      );
    }
    // dd/mm/yyyy
    final vn = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(text);
    if (vn != null) {
      return _fmtDate(
        DateTime(
          int.parse(vn.group(3)!),
          int.parse(vn.group(2)!),
          int.parse(vn.group(1)!),
        ),
      );
    }
    return null;
  }

  double? _parseDouble(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', ''));

  int? _parseInt(String raw) {
    final d = _parseDouble(raw);
    if (d == null || d != d.roundToDouble()) return null;
    return d.toInt();
  }

  Future<void> _pickAndImport() async {
    setState(() {
      _busy = true;
      _progressText = 'Waiting for file selection...';
      _errors = [];
      _importedCount = 0;
      _finished = false;
    });
    try {
      final picked = await pickExcelFile();
      if (picked == null) {
        if (mounted) {
          setState(() {
            _busy = false;
            _progressText = null;
          });
        }
        return;
      }

      setState(() => _progressText = 'Reading ${picked.name}...');
      final excel = Excel.decodeBytes(picked.bytes);
      if (excel.tables.isEmpty) {
        throw Exception('The file has no sheets.');
      }
      final sheet = excel.tables[excel.tables.keys.first]!;

      // Locate the header row (first row containing "barcode").
      var headerRowIndex = -1;
      final columnIndex = <String, int>{};
      for (var r = 0; r < sheet.rows.length && r < 10; r++) {
        final row = sheet.rows[r];
        for (var c = 0; c < row.length; c++) {
          if (_normalizeHeader(_cellText(row[c])) == 'barcode') {
            headerRowIndex = r;
            break;
          }
        }
        if (headerRowIndex >= 0) break;
      }
      if (headerRowIndex < 0) {
        throw Exception(
          'Header row not found. Use the template: the first row must '
          'contain a "Barcode" column.',
        );
      }
      final headerRow = sheet.rows[headerRowIndex];
      for (var c = 0; c < headerRow.length; c++) {
        final key = _normalizeHeader(_cellText(headerRow[c]));
        if (key.isEmpty) continue;
        for (final canonical in [
          'barcode',
          'productname',
          'productbatch',
          'description',
          'category',
          'supplier',
          'costprice',
          'sellingprice',
          'cartons',
          'instock',
          'mftdate',
          'expirydate',
        ]) {
          if (key.startsWith(canonical) && !columnIndex.containsKey(canonical)) {
            columnIndex[canonical] = c;
          }
        }
      }
      const required = [
        'barcode',
        'productname',
        'productbatch',
        'category',
        'supplier',
        'costprice',
        'sellingprice',
        'cartons',
        'instock',
        'mftdate',
        'expirydate',
      ];
      final missing =
          required.where((k) => !columnIndex.containsKey(k)).toList();
      if (missing.isNotEmpty) {
        throw Exception('Missing columns: ${missing.join(', ')}');
      }

      setState(() => _progressText = 'Loading categories & suppliers...');
      final categories = await _productApiService.getCategoryOptions();
      final suppliers = await _productApiService.getSupplierOptions();
      final categoryByName = {
        for (final c in categories) c.name.trim().toLowerCase(): c.id,
      };
      final supplierByName = {
        for (final s in suppliers) s.supplierName.trim().toLowerCase(): s.id,
      };

      String cellAt(List<Data?> row, String key) {
        final idx = columnIndex[key]!;
        return idx < row.length ? _cellText(row[idx]) : '';
      }

      final requests = <(int rowNo, CreateProductRequest request)>[];
      final errors = <String>[];
      for (var r = headerRowIndex + 1; r < sheet.rows.length; r++) {
        final row = sheet.rows[r];
        final rowNo = r + 1;
        final barcode = cellAt(row, 'barcode');
        final name = cellAt(row, 'productname');
        if (barcode.isEmpty && name.isEmpty) {
          continue; // skip fully empty rows
        }
        final rowErrors = <String>[];
        if (barcode.isEmpty) rowErrors.add('barcode is empty');
        if (name.isEmpty) rowErrors.add('product name is empty');
        final batch = cellAt(row, 'productbatch');
        if (batch.isEmpty) rowErrors.add('product batch is empty');

        final categoryName = cellAt(row, 'category').trim().toLowerCase();
        final categoryId = categoryByName[categoryName];
        if (categoryId == null) {
          rowErrors.add('category "${cellAt(row, 'category')}" not found');
        }
        final supplierName = cellAt(row, 'supplier').trim().toLowerCase();
        final supplierId = supplierByName[supplierName];
        if (supplierId == null) {
          rowErrors.add('supplier "${cellAt(row, 'supplier')}" not found');
        }

        final costPrice = _parseDouble(cellAt(row, 'costprice'));
        if (costPrice == null || costPrice < 0) {
          rowErrors.add('invalid cost price');
        }
        final sellingPrice = _parseDouble(cellAt(row, 'sellingprice'));
        if (sellingPrice == null || sellingPrice < 0) {
          rowErrors.add('invalid selling price');
        }
        final cartons = _parseInt(cellAt(row, 'cartons'));
        if (cartons == null || cartons < 0) rowErrors.add('invalid cartons');
        final inStock = _parseInt(cellAt(row, 'instock'));
        if (inStock == null || inStock < 0) rowErrors.add('invalid in stock');

        final mftDate = _parseDate(cellAt(row, 'mftdate'));
        if (mftDate == null) rowErrors.add('invalid MFT date');
        final expiryDate = _parseDate(cellAt(row, 'expirydate'));
        if (expiryDate == null) rowErrors.add('invalid expiry date');

        if (rowErrors.isNotEmpty) {
          errors.add('Row $rowNo: ${rowErrors.join('; ')}');
          continue;
        }
        requests.add((
          rowNo,
          CreateProductRequest(
            barcode: barcode,
            productBatch: batch,
            productName: name,
            description: cellAt(row, 'description'),
            costPrice: costPrice!,
            sellingPrice: sellingPrice!,
            cartons: cartons!,
            qtyCartons: inStock!,
            supplierId: supplierId!,
            categoryId: categoryId!,
            mftDate: mftDate!,
            expiryDate: expiryDate!,
          ),
        ));
      }

      if (requests.isEmpty && errors.isEmpty) {
        throw Exception('No data rows found in the file.');
      }

      var imported = 0;
      for (var i = 0; i < requests.length; i++) {
        final (rowNo, request) = requests[i];
        if (!mounted) return;
        setState(
          () => _progressText = 'Importing ${i + 1}/${requests.length}...',
        );
        try {
          await _productApiService.createProduct(request);
          imported++;
        } catch (e) {
          errors.add(
            'Row $rowNo (${request.productName}): '
            '${e.toString().replaceFirst('Exception: ', '')}',
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _busy = false;
        _progressText = null;
        _importedCount = imported;
        _errors = errors;
        _finished = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _progressText = null;
        _errors = [e.toString().replaceFirst('Exception: ', '')];
        _finished = true;
        _importedCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Import Products from Excel',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _busy
                        ? null
                        : () =>
                              Navigator.of(context).pop(_importedCount > 0),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload an .xlsx file with the columns below. Category and '
                'Supplier must match existing names exactly. Download the '
                'template to get started.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  _templateHeaders.join(' | '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_progressText != null) ...[
                Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_progressText!)),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              if (_finished) ...[
                Text(
                  'Imported: $_importedCount product(s)'
                  '${_errors.isEmpty ? '' : ' · Failed: ${_errors.length}'}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _importedCount > 0
                        ? const Color(0xFF166534)
                        : const Color(0xFF991B1B),
                  ),
                ),
                if (_errors.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 160),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final e in _errors)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                e,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _downloadTemplate,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Download template'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _busy ? null : _pickAndImport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: Text(
                      _finished ? 'Import another file' : 'Choose file & import',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
