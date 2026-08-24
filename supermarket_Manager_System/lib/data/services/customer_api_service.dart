import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/customer_detail.dart';
import 'package:supermarket_manager_system/domain/models/customer_list_item.dart';
import 'package:supermarket_manager_system/domain/models/order_list_item.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class CustomerApiService {
  Future<List<CustomerListItem>> getCustomers() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.customersPath}',
    );
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load customers');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid customers response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CustomerListItem.fromJson)
        .toList();
  }

  Future<CustomerDetail> getCustomerDetail(int customerId) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.customersPath}/$customerId',
    );
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.body.isNotEmpty) {
        throw Exception(response.body);
      }
      throw Exception('Failed to load customer details');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid customer detail response format');
    }
    return CustomerDetail.fromJson(decoded);
  }

  Future<CustomerListItem> getCustomerByPhone(String phone) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.customersPath}/by-phone'
      '?phone=${Uri.encodeQueryComponent(phone.trim())}',
    );
    final response = await http.get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return CustomerListItem.fromJson(decoded);
      }
      throw Exception('Invalid customer by phone response');
    }
    if (response.body.isNotEmpty) {
      throw Exception(response.body);
    }
    throw Exception('Customer not found by phone');
  }

  Future<CustomerListItem> createCustomer({
    required String name,
    required String phone,
    double? totalAmount,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.customersPath}',
    );
    final Map<String, dynamic> body = {
      'name': name.trim(),
      'phone': phone.trim(),
    };
    if (totalAmount != null) {
      body['totalAmount'] = totalAmount;
    }

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return CustomerListItem.fromJson(decoded);
      }
      throw Exception('Invalid create customer response');
    }
    if (response.body.isNotEmpty) {
      throw Exception(response.body);
    }
    throw Exception('Failed to create customer');
  }

  Future<CustomerListItem> updateCustomer({
    required int customerId,
    required String name,
    required String phone,
    double? totalAmount,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.customersPath}/$customerId',
    );
    final Map<String, dynamic> body = {
      'name': name.trim(),
      'phone': phone.trim(),
    };
    if (totalAmount != null) {
      body['totalAmount'] = totalAmount;
    }

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return CustomerListItem.fromJson(decoded);
      }
      throw Exception('Invalid update customer response');
    }
    if (response.body.isNotEmpty) {
      throw Exception(response.body);
    }
    throw Exception('Failed to update customer');
  }

  Future<List<OrderListItem>> getCustomerOrderHistory(int customerId) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.customersPath}/$customerId/history',
    );
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.body.isNotEmpty) {
        throw Exception(response.body);
      }
      throw Exception('Failed to load customer order history');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid customer history response format');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(OrderListItem.fromJson)
        .toList();
  }
}
