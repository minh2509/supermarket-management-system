import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/supplier_list_item.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class SupplierApiService {
  Future<List<SupplierListItem>> getSuppliers() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.suppliersPath}');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load suppliers');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid suppliers response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(SupplierListItem.fromJson)
        .toList();
  }

  Future<SupplierListItem> getSupplierById(int id) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.suppliersPath}/$id',
    );
    final response = await http.get(uri);

    if (response.statusCode == 404) {
      throw Exception('Supplier not found');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load supplier');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return SupplierListItem.fromJson(decoded);
  }

  Future<void> createSupplier({
    required String supplierName,
    String? companyName,
    String? email,
    String? phone,
    String? address,
    String? status,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.suppliersPath}');
    final body = <String, dynamic>{
      "supplierName": supplierName.trim(),
      "companyName": companyName?.trim().isEmpty ?? true ? null : companyName!.trim(),
      "email": email?.trim().isEmpty ?? true ? null : email!.trim(),
      "phone": phone?.trim().isEmpty ?? true ? null : phone!.trim(),
      "address": address?.trim().isEmpty ?? true ? null : address!.trim(),
      "status": status?.trim().isEmpty ?? true ? null : status!.trim(),
    };
    final response = await http.post(
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
    throw Exception('Failed to create supplier');
  }

  Future<void> updateSupplier({
    required int id,
    required String supplierName,
    String? companyName,
    String? email,
    String? phone,
    String? address,
    String? status,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.suppliersPath}/$id',
    );
    final body = <String, dynamic>{
      "supplierName": supplierName.trim(),
      "companyName": companyName?.trim().isEmpty ?? true ? null : companyName!.trim(),
      "email": email?.trim().isEmpty ?? true ? null : email!.trim(),
      'phone': phone?.trim().isEmpty ?? true ? null : phone!.trim(),
      'address': address?.trim().isEmpty ?? true ? null : address!.trim(),
      'status': status?.trim().isEmpty ?? true ? null : status!.trim(),
    };
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 404) {
      throw Exception('Supplier not found');
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    if (response.body.isNotEmpty) {
      throw Exception(response.body);
    }
    throw Exception('Failed to update supplier');
  }

  Future<void> deleteSupplier(int id) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.suppliersPath}/$id',
    );
    final response = await http.delete(uri);

    if (response.statusCode == 404) {
      throw Exception('Supplier not found');
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    if (response.body.isNotEmpty) {
      throw Exception(response.body);
    }
    throw Exception('Failed to delete supplier');
  }
}
