import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/revenue_report_item.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class ReportApiService {
  Future<List<RevenueReportItem>> getRevenueReport({
    required int year,
    int? month,
  }) async {
    final queryParams = <String, String>{'year': year.toString()};
    if (month != null) queryParams['month'] = month.toString();

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.revenueReportPath}')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load revenue report');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(RevenueReportItem.fromJson)
        .toList();
  }
}
