import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/discount.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class DiscountApiService {
  Future<List<Discount>> getDiscounts() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.discountsPath}',
    );
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load discounts');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid discounts response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Discount.fromJson)
        .toList();
  }

  Future<Discount> createDiscount(Discount discount) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.discountsPath}',
    );
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(discount.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return Discount.fromJson(decoded);
      }
      throw Exception('Invalid create discount response');
    }
    throw Exception(response.body.isNotEmpty ? response.body : 'Failed to create discount');
  }

  Future<Discount> updateDiscount(int id, Discount discount) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.discountsPath}/$id',
    );
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(discount.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return Discount.fromJson(decoded);
      }
      throw Exception('Invalid update discount response');
    }
    throw Exception(response.body.isNotEmpty ? response.body : 'Failed to update discount');
  }

  Future<void> deleteDiscount(int id) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.discountsPath}/$id',
    );
    final response = await http.delete(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(response.body.isNotEmpty ? response.body : 'Failed to delete discount');
    }
  }
}
