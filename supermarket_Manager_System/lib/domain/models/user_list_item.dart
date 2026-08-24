class UserListItem {
  const UserListItem({
    required this.id,
    required this.fullname,
    required this.username,
    required this.email,
    required this.role,
    required this.status,
    required this.idCard,
  });

  final int id;
  final String fullname;
  final String username;
  final String email;
  final String role;
  final String status;
  final String idCard;

  factory UserListItem.fromJson(Map<String, dynamic> json) {
    return UserListItem(
      id: json['id'] as int? ?? 0,
      fullname: (json['fullname'] as String?) ?? '',
      username: (json['username'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      idCard: (json['idCard'] as String?) ?? '',
    );
  }
}
