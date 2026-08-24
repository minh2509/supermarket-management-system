class Discount {
  const Discount({
    required this.id,
    required this.name,
    required this.percent,
    required this.minOrderAmount,
    required this.startDate,
    required this.endDate,
  });

  final int id;
  final String name;
  final double percent;
  final double minOrderAmount;
  final DateTime startDate;
  final DateTime endDate;

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '—',
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : DateTime.now(),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'percent': percent,
      'minOrderAmount': minOrderAmount,
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
    };
  }
}
