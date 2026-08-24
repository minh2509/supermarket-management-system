class SupplierOption {
  const SupplierOption({
    required this.id,
    required this.supplierName,
  });

  final int id;
  final String supplierName;

  factory SupplierOption.fromJson(Map<String, dynamic> json) {
    return SupplierOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      supplierName: json['supplierName'] as String? ?? '',
    );
  }
}
