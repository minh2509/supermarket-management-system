import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/category_list_item.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class CategoryApiService {
  Future<List<CategoryListItem>> getCategories() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categoriesPath}');
    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Request timeout (getCategories)');
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to load categories (HTTP ${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid categories response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CategoryListItem.fromJson)
        .toList();
  }

  Future<CategoryListItem> getCategoryById(int id) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.categoriesPath}/$id',
    );
    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Request timeout (getCategoryById)');
    });

    if (response.statusCode == 404) {
      throw Exception('Category not found');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to load category (HTTP ${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return CategoryListItem.fromJson(decoded);
  }

  Future<CategoryListItem> createCategory({
    required String name,
    required String status,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categoriesPath}');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name.trim(),
            'status': status.trim(),
          }),
        )
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Request timeout (createCategory)');
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(response.body.isNotEmpty ? response.body : 'Failed to create category');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return CategoryListItem.fromJson(decoded);
  }

  Future<CategoryListItem> updateCategory({
    required int id,
    required String name,
    required String status,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.categoriesPath}/$id',
    );
    final response = await http
        .put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name.trim(),
            'status': status.trim(),
          }),
        )
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Request timeout (updateCategory)');
    });

    if (response.statusCode == 404) {
      throw Exception('Category not found');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(response.body.isNotEmpty ? response.body : 'Failed to update category');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return CategoryListItem.fromJson(decoded);
  }

  Future<void> deleteCategory(int id) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.categoriesPath}/$id',
    );
    final response = await http
        .delete(uri)
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Request timeout (deleteCategory)');
    });

    if (response.statusCode == 404) {
      throw Exception('Category not found');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(response.body.isNotEmpty ? response.body : 'Failed to delete category');
    }
  }
}

