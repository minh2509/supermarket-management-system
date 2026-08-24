import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/expiration_product.dart';
import 'package:supermarket_manager_system/domain/models/expiration_stats.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class ExpirationApiService {
  Future<ExpirationStats> getExpirationStats() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/expiration/stats');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load expiration stats');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ExpirationStats.fromJson(decoded);
  }

  Future<List<ExpirationProduct>> getProductsExpiringToday() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/expiration/today');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load products');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ExpirationProduct.fromJson)
        .toList();
  }

  Future<List<ExpirationProduct>> getProductsExpiringIn7Days() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/expiration/7days');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load products');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ExpirationProduct.fromJson)
        .toList();
  }

  Future<List<ExpirationProduct>> getProductsExpiringIn3Months() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/expiration/3months');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load products');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ExpirationProduct.fromJson)
        .toList();
  }

  Future<List<ExpirationProduct>> getProductsExpiringIn6Months() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/expiration/6months');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load products');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ExpirationProduct.fromJson)
        .toList();
  }
}
