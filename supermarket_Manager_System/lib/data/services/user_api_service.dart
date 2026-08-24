import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/role_option.dart';
import 'package:supermarket_manager_system/domain/models/user_detail.dart';
import 'package:supermarket_manager_system/domain/models/user_list_item.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class UserApiService {
  Future<List<UserListItem>> getUsers() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersPath}');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load users');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid users response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(UserListItem.fromJson)
        .toList();
  }

  Future<void> createUser({
    required String fullname,
    required String username,
    required String email,
    required String password,
    required String userRole,
    String? idCard,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersPath}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullname': fullname,
        'username': username,
        'email': email,
        'password': password,
        'idCard': (idCard == null || idCard.trim().isEmpty) ? null : idCard.trim(),
        'userRole': userRole,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    if (response.body.isNotEmpty) {
      throw Exception(response.body);
    }
    throw Exception('Failed to create user');
  }

  Future<List<RoleOption>> getRoles() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userRolesPath}');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load roles');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid roles response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(RoleOption.fromJson)
        .where((role) => role.name.isNotEmpty)
        .toList();
  }

  Future<UserDetail> getUserDetail(int userId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersPath}/$userId');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load user details');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid user detail response format');
    }

    return UserDetail.fromJson(decoded);
  }

  Future<void> updateUser({
    required int userId,
    required String fullname,
    required String username,
    required String email,
    required String userRole,
    String? idCard,
    String? password,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersPath}/$userId');
    final body = <String, dynamic>{
      'fullname': fullname,
      'username': username,
      'email': email,
      'idCard': (idCard == null || idCard.trim().isEmpty) ? null : idCard.trim(),
      'userRole': userRole,
    };
    if (password != null && password.trim().isNotEmpty) {
      body['password'] = password.trim();
    }

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    if (response.body.isNotEmpty) {
      throw Exception(response.body);
    }
    throw Exception('Failed to update user');
  }

  Future<void> updateUserStatus({
    required int userId,
    required String status,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersPath}/$userId/status');
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    if (response.body.isNotEmpty) {
      throw Exception(response.body);
    }
    throw Exception('Failed to update user status');
  }

  Future<UserDetail> updateProfile({
    required int userId,
    required String fullname,
    required String email,
    String? idCard,
    String? phone,
    String? address,
    String? dob,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersPath}/$userId/profile');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullname': fullname,
        'email': email,
        'idCard': (idCard == null || idCard.trim().isEmpty) ? null : idCard.trim(),
        'phone': (phone == null || phone.trim().isEmpty) ? null : phone.trim(),
        'address': (address == null || address.trim().isEmpty) ? null : address.trim(),
        'dob': (dob == null || dob.trim().isEmpty) ? null : dob.trim(),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.body.isNotEmpty) {
        throw Exception(response.body);
      }
      throw Exception('Failed to update profile');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid update profile response format');
    }
    return UserDetail.fromJson(decoded);
  }

  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersPath}/$userId/password');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    if (response.body.isNotEmpty) {
      throw Exception(response.body);
    }
    throw Exception('Failed to change password');
  }
}
