import 'package:excel/excel.dart' hide Border, TextSpan;
import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/order_api_service.dart';
import 'package:supermarket_manager_system/domain/models/order_list_item.dart';
import 'package:supermarket_manager_system/utils/excel_saver.dart';

class RevenueReportPage extends StatefulWidget {
  final String fullName;
  final bool isCompact;
  final String currentTimeText;
  final VoidCallback? onProfileTap;

  const RevenueReportPage({
    super.key,
    required this.fullName,
    this.isCompact = false,
    this.currentTimeText = '',
    this.onProfileTap,
  });

  @override
  State<RevenueReportPage> createState() => _RevenueReportPageState();
}

class _RevenueReportPageState extends State<RevenueReportPage> {
  final _service = OrderApiService();

  bool _loading = false;
  String? _error;
  List<OrderListItem> _allOrders = [];
  List<OrderListItem> _filteredOrders = [];

  late DateTime _fromDate;
  late DateTime _toDate;
  String _selectedPayment = 'All Payments';

  // AI Chatbox state
  bool _isChatOpen = false;
  final TextEditingController _chatController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'text':
          'Xin chào! Tôi là trợ lý AI. Bạn có thể nhập câu hỏi về báo cáo, doanh thu hoặc bất kỳ thắc mắc nào.',
      'isUser': false,
    },
  ];

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = now;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getOrders();
      _allOrders = data;
      _applyFilter();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _applyFilter() {
    if (_fromDate.isAfter(_toDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: "From Date" cannot be after "To Date"'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _filteredOrders = _allOrders.where((o) {
        final date = o.createdAt;
        final d = DateTime(date.year, date.month, date.day);
        final from = DateTime(_fromDate.year, _fromDate.month, _fromDate.day);
        final to = DateTime(_toDate.year, _toDate.month, _toDate.day);

        if (d.isBefore(from) || d.isAfter(to)) return false;
        if (_selectedPayment != 'All Payments' &&
            o.paymentMethod != _selectedPayment) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  // Formatting helpers
  String _formatMoney(double v) {
    if (v == 0) return '0đ';
    final fmt = v
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$fmtđ';
  }

  static const _monthNames = [
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Summaries
  double get _totalRevenue =>
      _filteredOrders.fold(0, (sum, o) => sum + o.payable);
  double _paymentSum(String method) => _filteredOrders
      .where((o) => o.paymentMethod.toLowerCase() == method.toLowerCase())
      .fold(0, (sum, o) => sum + o.payable);

  bool _exporting = false;

  String _fileDatePart(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  Future<void> _exportExcel() async {
    if (_exporting) {
      return;
    }
    if (_filteredOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sales records to export.')),
      );
      return;
    }
    setState(() => _exporting = true);
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Sales Report'];
      excel.delete('Sheet1');

      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#F1F5F9'),
      );

      sheet.appendRow([
        TextCellValue(
          'Sales Report ${_formatDate(_fromDate)} - ${_formatDate(_toDate)}',
        ),
      ]);
      sheet.appendRow([
        TextCellValue('Payment filter: $_selectedPayment'),
      ]);
      sheet.appendRow([TextCellValue('')]);

      const headers = [
        'Order ID',
        'Date',
        'Customer',
        'Phone',
        'Total',
        'Discount (%)',
        'Payable',
        'Payment Method',
        'Status',
        'Cashier',
      ];
      final headerRowIndex = sheet.maxRows;
      sheet.appendRow([for (final h in headers) TextCellValue(h)]);
      for (var col = 0; col < headers.length; col++) {
        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: col,
                rowIndex: headerRowIndex,
              ),
            )
            .cellStyle = headerStyle;
      }

      for (final o in _filteredOrders) {
        sheet.appendRow([
          TextCellValue(o.orderNo),
          TextCellValue(_formatDate(o.createdAt)),
          TextCellValue(o.customerName),
          TextCellValue(o.customerPhone),
          DoubleCellValue(o.total),
          DoubleCellValue(o.discountPercent),
          DoubleCellValue(o.payable),
          TextCellValue(o.paymentMethod),
          TextCellValue(o.status),
          TextCellValue(o.cashierName),
        ]);
      }

      sheet.appendRow([TextCellValue('')]);
      sheet.appendRow([
        TextCellValue('Cash'),
        DoubleCellValue(_paymentSum('Cash')),
      ]);
      sheet.appendRow([
        TextCellValue('Transfer'),
        DoubleCellValue(_paymentSum('Transfer')),
      ]);
      sheet.appendRow([
        TextCellValue('POS'),
        DoubleCellValue(_paymentSum('POS')),
      ]);
      sheet.appendRow([
        TextCellValue('Cheque'),
        DoubleCellValue(_paymentSum('Cheque')),
      ]);
      final totalRowIndex = sheet.maxRows;
      sheet.appendRow([
        TextCellValue('Total Revenue'),
        DoubleCellValue(_totalRevenue),
      ]);
      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: 0,
              rowIndex: totalRowIndex,
            ),
          )
          .cellStyle = CellStyle(
        bold: true,
      );

      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('Failed to encode the Excel file.');
      }
      final fileName =
          'sales_report_${_fileDatePart(_fromDate)}_${_fileDatePart(_toDate)}.xlsx';
      final savedPath = await saveExcelFile(bytes, fileName);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savedPath == null
                ? 'Excel file "$fileName" downloaded.'
                : 'Excel file saved: $savedPath',
          ),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Export failed: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  void _sendAiMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _chatMessages.add({'text': text, 'isUser': true});
      _chatController.clear();
    });

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final q = text.toLowerCase();
      String reply =
          'Cảm ơn bạn đã gửi câu hỏi. Đây là tính năng trợ lý AI demo. Bạn có thể kết nối API AI thực tế để nhận câu trả lời.';
      if (q.contains('doanh thu') || q.contains('revenue')) {
        reply =
            'Tổng doanh thu hiện tại trong báo cáo là ${_formatMoney(_totalRevenue)}. Bạn có thể xem chi tiết trong bảng phía trên.';
      } else if (q.contains('báo cáo') || q.contains('report')) {
        reply =
            'Đây là trang Sales Report. Bạn có thể lọc theo khoảng thời gian, loại thanh toán và xuất Excel. Nếu cần phân tích sâu hơn, hãy mô tả cụ thể.';
      } else if (q.contains('xin chào') || q.contains('hello')) {
        reply =
            'Xin chào! Tôi có thể hỗ trợ bạn về báo cáo bán hàng, doanh thu và dữ liệu trên trang này.';
      }
      setState(() {
        _chatMessages.add({'text': reply, 'isUser': false});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFF4F7FC),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                        child: Text(
                          'Error: $_error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: ListView(
                          controller: _scrollController,
                          padding: EdgeInsets.all(widget.isCompact ? 14 : 24),
                          children: [
                            // Title
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E7FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.analytics,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Sales Report for ${_monthNames[_fromDate.month - 1]}, ${_fromDate.year}',
                                    style: TextStyle(
                                      fontSize: widget.isCompact ? 16 : 24,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1D21),
                                      letterSpacing: -0.02,
                                    ),
                                    maxLines: widget.isCompact ? 2 : 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: widget.isCompact ? 14 : 24),
                            _buildPaymentCards(),
                            SizedBox(height: widget.isCompact ? 14 : 24),
                            _buildFilters(),
                            SizedBox(height: widget.isCompact ? 14 : 24),
                            _buildTable(),
                            const SizedBox(height: 16),
                            _buildTotalBanner(),
                            SizedBox(height: widget.isCompact ? 84 : 24),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        // AI Chatbox UI
        if (_isChatOpen)
          Positioned(right: 24, bottom: 90, child: _buildAiChatBox()),
        // AI FAB
        Positioned(
          right: 24,
          bottom: 24,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF6366F1),
            onPressed: () {
              setState(() => _isChatOpen = !_isChatOpen);
            },
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.isCompact)
            Builder(
              builder: (ctx) => IconButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            )
          else
            const Text(
              'Sales Report',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          Row(
            children: [
              if (widget.currentTimeText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.currentTimeText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.fullName.isEmpty ? 'Admin' : widget.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    'Administrator',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onProfileTap,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.fullName.isNotEmpty
                        ? widget.fullName[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (widget.isCompact) {
          const spacing = 10.0;
          final itemWidth = (constraints.maxWidth - spacing) / 2;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              SizedBox(
                width: itemWidth,
                child: _buildPaymentCard(
                  Icons.payments_outlined,
                  'Cash',
                  _paymentSum('Cash'),
                  const Color(0xFF4CAF50),
                  Colors.white,
                  compact: true,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _buildPaymentCard(
                  Icons.swap_horiz_rounded,
                  'Transfer',
                  _paymentSum('Transfer'),
                  const Color(0xFFDC2626),
                  Colors.white,
                  compact: true,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _buildPaymentCard(
                  Icons.credit_card_outlined,
                  'POS',
                  _paymentSum('POS'),
                  const Color(0xFFEAB308),
                  const Color(0xFF1A1D21),
                  compact: true,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _buildPaymentCard(
                  Icons.description_outlined,
                  'Cheque',
                  _paymentSum('Cheque'),
                  const Color(0xFF38BDF8),
                  Colors.white,
                  compact: true,
                ),
              ),
            ],
          );
        }

        return GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.0,
          children: [
            _buildPaymentCard(
              Icons.payments_outlined,
              'Cash Payment',
              _paymentSum('Cash'),
              const Color(0xFF4CAF50),
              Colors.white,
            ),
            _buildPaymentCard(
              Icons.swap_horiz_rounded,
              'Transfer Payment',
              _paymentSum('Transfer'),
              const Color(0xFFDC2626),
              Colors.white,
            ),
            _buildPaymentCard(
              Icons.credit_card_outlined,
              'POS Payment',
              _paymentSum('POS'),
              const Color(0xFFEAB308),
              const Color(0xFF1A1D21),
            ),
            _buildPaymentCard(
              Icons.description_outlined,
              'Cheque Payment',
              _paymentSum('Cheque'),
              const Color(0xFF38BDF8),
              Colors.white,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentCard(
    IconData iconData,
    String label,
    double amount,
    Color bgColor,
    Color textColor, {
    bool compact = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(compact ? 10 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: compact ? 34 : 48,
            height: compact ? 34 : 48,
            decoration: BoxDecoration(
              color: bgColor == const Color(0xFFEAB308)
                  ? const Color(0x26000000)
                  : Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(iconData, size: compact ? 18 : 26, color: textColor),
          ),
          SizedBox(width: compact ? 8 : 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 2 : 4),
                Text(
                  _formatMoney(amount),
                  style: TextStyle(
                    color: textColor,
                    fontSize: compact ? 13 : 20,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    if (widget.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You can filter sales record by date range',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
          const SizedBox(height: 12),
          _buildDatePicker(
            'FROM',
            _fromDate,
            (d) => setState(() => _fromDate = d),
            first: DateTime(2000),
            last: _toDate,
            compact: true,
          ),
          const SizedBox(height: 10),
          _buildDatePicker(
            'TO',
            _toDate,
            (d) => setState(() => _toDate = d),
            first: _fromDate,
            last: DateTime.now(),
            compact: true,
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 40,
                  alignment: Alignment.center,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPayment,
                      isExpanded: true,
                      isDense: true,
                      items:
                          ['All Payments', 'Cash', 'Transfer', 'POS', 'Cheque']
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedPayment = v);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: _applyFilter,
                    icon: const Icon(Icons.search, size: 16),
                    label: const Text('Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1D21),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: _exporting ? null : _exportExcel,
                    icon: const Icon(Icons.bar_chart, size: 16),
                    label: Text(_exporting ? 'Exporting...' : 'Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'You can filter sales record by date range',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            _buildDatePicker(
              'FROM',
              _fromDate,
              (d) => setState(() => _fromDate = d),
              first: DateTime(2000),
              last: _toDate,
            ),
            const SizedBox(width: 16),
            _buildDatePicker(
              'TO',
              _toDate,
              (d) => setState(() => _toDate = d),
              first: _fromDate,
              last: DateTime.now(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 40,
                  alignment: Alignment.center,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPayment,
                      isDense: true,
                      items:
                          ['All Payments', 'Cash', 'Transfer', 'POS', 'Cheque']
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedPayment = v);
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () {
                  _applyFilter();
                },
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Search Record'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1D21),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: _exporting ? null : _exportExcel,
                icon: const Icon(Icons.bar_chart, size: 18),
                label: Text(_exporting ? 'Exporting...' : 'Export Excel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime date,
    Function(DateTime) onPicked, {
    DateTime? first,
    DateTime? last,
    bool compact = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final d = await showDatePicker(
              context: context,
              initialDate: date.isAfter(last ?? now)
                  ? (last ?? now)
                  : (date.isBefore(first ?? DateTime(2000))
                        ? (first ?? DateTime(2000))
                        : date),
              firstDate: first ?? DateTime(2000),
              lastDate: last ?? now,
            );
            if (d != null) onPicked(d);
          },
          child: Container(
            height: 40,
            width: compact ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DB)),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              _formatDate(date),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    if (widget.isCompact) {
      return _buildMobileOrdersList();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF7F8FA),
                ),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A5568),
                  fontSize: 12,
                ),
                columns: const [
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Discount (%)')),
                  DataColumn(label: Text('Payable')),
                  DataColumn(label: Text('Payment Method')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Cashier')),
                ],
                rows: _filteredOrders.map((o) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          o.orderNo,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(Text(o.customerPhone)),
                      DataCell(Text(_formatMoney(o.total))),
                      DataCell(Text(o.discountPercent.toStringAsFixed(0))),
                      DataCell(
                        Text(
                          _formatMoney(o.payable),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(o.paymentMethod.isEmpty ? '—' : o.paymentMethod),
                      ),
                      DataCell(Text(o.status.isEmpty ? '—' : o.status)),
                      DataCell(
                        Text(o.cashierName.isEmpty ? '—' : o.cashierName),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileOrdersList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredOrders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final o = _filteredOrders[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EAF4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      o.orderNo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CompactStatusBadge(status: o.status.isEmpty ? '—' : o.status),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ReportInfoChip(label: 'Phone', value: o.customerPhone),
                  _ReportInfoChip(
                    label: 'Total',
                    value: _formatMoney(o.total),
                  ),
                  _ReportInfoChip(
                    label: 'Payable',
                    value: _formatMoney(o.payable),
                    valueColor: const Color(0xFF166534),
                  ),
                  _ReportInfoChip(
                    label: 'Payment',
                    value: o.paymentMethod.isEmpty ? '—' : o.paymentMethod,
                  ),
                  _ReportInfoChip(
                    label: 'Cashier',
                    value: o.cashierName.isEmpty ? '—' : o.cashierName,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalBanner() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCompact ? 14 : 20,
        vertical: widget.isCompact ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tổng doanh thu',
            style: TextStyle(
              fontSize: widget.isCompact ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF166534),
            ),
          ),
          Text(
            _formatMoney(_totalRevenue),
            style: TextStyle(
              fontSize: widget.isCompact ? 16 : 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF166534),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiChatBox() {
    return Container(
      width: 380,
      height: 480,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Trợ lý AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => setState(() => _isChatOpen = false),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: Container(
              color: const Color(0xFFF9FAFB),
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = _chatMessages[index];
                  final isUser = msg['isUser'] as bool;
                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: isUser ? null : Colors.white,
                        gradient: isUser
                            ? const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                              )
                            : null,
                        border: isUser
                            ? null
                            : Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg['text'] as String,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : const Color(0xFF374151),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Nhập câu hỏi...',
                      hintStyle: const TextStyle(fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _sendAiMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _sendAiMessage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Gửi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _ReportInfoChip extends StatelessWidget {
  const _ReportInfoChip({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(10),
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
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: valueColor ?? const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactStatusBadge extends StatelessWidget {
  const _CompactStatusBadge({required this.status});

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
        : const Color(0xFFE5E7EB);
    final fg = isPaid
        ? const Color(0xFF065F46)
        : isPending
        ? const Color(0xFF92400E)
        : const Color(0xFF374151);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
