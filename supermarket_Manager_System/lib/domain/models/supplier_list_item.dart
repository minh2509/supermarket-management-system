class SupplierListItem {
  const SupplierListItem({
    required this.id,
    required this.supplierName,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    this.createdAt,
  });

  final int id;
  final String supplierName;
  final String companyName;
  final String email;
  final String phone;
  final String address;
  final String status;
  final String? createdAt;

  factory SupplierListItem.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    return SupplierListItem(
      id: json['id'] as int? ?? 0,
      supplierName: (json['supplierName'] as String?) ?? '',
      companyName: (json['companyName'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      createdAt: createdAt?.toString(),
    );
  }
}
