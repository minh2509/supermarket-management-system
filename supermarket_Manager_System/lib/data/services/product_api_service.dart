import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/category_option.dart';
import 'package:supermarket_manager_system/domain/models/create_product_request.dart';
import 'package:supermarket_manager_system/domain/models/product_detail.dart';
import 'package:supermarket_manager_system/domain/models/product_list_item.dart';
import 'package:supermarket_manager_system/domain/models/supplier_option.dart';
import 'package:supermarket_manager_system/domain/models/update_product_request.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class ProductApiService {
  Future<List<ProductListItem>> getProducts() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsPath}');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load products');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid products response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ProductListItem.fromJson)
        .toList();
  }

  Future<ProductDetail> getProductById(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsPath}/$id');
    final response = await http.get(uri);

    if (response.statusCode == 404) {
      throw Exception('Product not found');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load product');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductDetail.fromJson(decoded);
  }

  Future<ProductDetail> createProduct(CreateProductRequest request) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsPath}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage = 'Failed to create product';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody['message'] != null) {
          errorMessage = errorBody['message'];
        }
      } catch (_) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw Exception(errorMessage);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductDetail.fromJson(decoded);
  }

  Future<void> deleteProduct(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsPath}/$id');
    final response = await http.delete(uri);

    if (response.statusCode == 404) {
      throw Exception('Product not found');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage = 'Failed to delete product';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody['message'] != null) {
          errorMessage = errorBody['message'];
        }
      } catch (_) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

  Future<ProductDetail> updateProduct(int id, UpdateProductRequest request) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsPath}/$id');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 404) {
      throw Exception('Product not found');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage = 'Failed to update product';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody['message'] != null) {
          errorMessage = errorBody['message'];
        }
      } catch (_) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw Exception(errorMessage);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductDetail.fromJson(decoded);
  }

  Future<List<SupplierOption>> getSupplierOptions() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.suppliersPath}/options');
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
        .map(SupplierOption.fromJson)
        .toList();
  }

  Future<List<CategoryOption>> getCategoryOptions() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/categories/options');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load categories');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid categories response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CategoryOption.fromJson)
        .toList();
  }
}

