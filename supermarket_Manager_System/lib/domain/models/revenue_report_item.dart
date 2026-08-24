class RevenueReportItem {
  final String label;
  final double totalRevenue;
  final int orderCount;

  RevenueReportItem({
    required this.label,
    required this.totalRevenue,
    required this.orderCount,
  });

  factory RevenueReportItem.fromJson(Map<String, dynamic> json) {
    return RevenueReportItem(
      label: json['label']?.toString() ?? '',
      totalRevenue: _toDouble(json['totalRevenue']),
      orderCount: _toInt(json['orderCount']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
