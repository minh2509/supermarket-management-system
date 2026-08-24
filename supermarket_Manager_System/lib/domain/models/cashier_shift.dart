class CashierShift {
  const CashierShift({
    required this.id,
    required this.userId,
    required this.employeeName,
    required this.salesPoint,
    required this.openTime,
    required this.closeTime,
    required this.initialCash,
    required this.cashRevenue,
    required this.revenue,
    required this.systemCashEnd,
    required this.totalCashEnd,
    required this.difference,
    required this.orderCount,
    required this.status,
  });

  final int id;
  final int userId;
  final String employeeName;
  final String salesPoint;
  final DateTime openTime;
  final DateTime? closeTime;
  final double initialCash;
  final double cashRevenue;
  final double revenue;
  final double systemCashEnd;
  final double? totalCashEnd;
  final double? difference;
  final int orderCount;
  final String status;

  bool get isOpen => status.toUpperCase() == 'OPEN';

  factory CashierShift.fromJson(Map<String, dynamic> json) {
    return CashierShift(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      employeeName: json['employeeName'] as String? ?? 'Cashier',
      salesPoint: json['salesPoint'] as String? ?? 'Main Store',
      openTime:
          DateTime.tryParse(json['openTime'] as String? ?? '') ??
          DateTime.now(),
      closeTime: DateTime.tryParse(json['closeTime'] as String? ?? ''),
      initialCash: (json['initialCash'] as num?)?.toDouble() ?? 0,
      cashRevenue: (json['cashRevenue'] as num?)?.toDouble() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      systemCashEnd: (json['systemCashEnd'] as num?)?.toDouble() ?? 0,
      totalCashEnd: (json['totalCashEnd'] as num?)?.toDouble(),
      difference: (json['difference'] as num?)?.toDouble(),
      orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'OPEN',
    );
  }
}
