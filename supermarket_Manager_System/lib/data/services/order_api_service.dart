import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/dashboard_summary.dart';
import 'package:supermarket_manager_system/domain/models/dashboard_transaction.dart';
import 'package:supermarket_manager_system/domain/models/checkout_invoice.dart';
import 'package:supermarket_manager_system/domain/models/order_detail.dart';
import 'package:supermarket_manager_system/domain/models/order_list_item.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class OrderApiService {
  Future<List<OrderListItem>> getOrders() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ordersPath}');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load orders');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid orders response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(OrderListItem.fromJson)
        .toList();
  }

  Future<OrderDetail> getOrderDetail(int orderId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ordersPath}/$orderId');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load order detail');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid order detail response format');
    }
    return OrderDetail.fromJson(decoded);
  }

  Future<DashboardSummary> getDashboardSummary() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dashboardPath}');
    final response = await http.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load dashboard summary');
    }
    final decoded = jsonDecode(response.body);
    return DashboardSummary.fromJson(decoded as Map<String, dynamic>);
  }

  Future<List<DashboardTransaction>> getTodayTransactions() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dashboardTransactionsPath}');
    final response = await http.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load today transactions');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(DashboardTransaction.fromJson)
        .toList();
  }

  Future<CheckoutInvoice> checkout({
    required int cashierId,
    required String customerName,
    required String customerPhone,
    required String paymentMethod,
    required double paid,
    required double discountPercent,
    int? discountId,
    String salesPoint = 'Main Store',
    required List<Map<String, dynamic>> items,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.ordersPath}/checkout',
    );
    final body = {
      'cashierId': cashierId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'salesPoint': salesPoint,
      'paymentMethod': paymentMethod,
      'paid': paid,
      'discountPercent': discountPercent,
      'discountId': discountId,
      'items': items,
    };
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.body.isNotEmpty) {
        throw Exception(response.body);
      }
      throw Exception('Failed to checkout order');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid checkout response format');
    }
    return CheckoutInvoice.fromJson(decoded);
  }
}


