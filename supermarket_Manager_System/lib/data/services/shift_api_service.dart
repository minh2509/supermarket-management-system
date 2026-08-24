import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/cashier_shift.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class ShiftApiService {
  Future<CashierShift?> getCurrentShift(int userId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.shiftsPath}/current/$userId',
      ),
    );
    if (response.statusCode == 404) return null;
    _ensureSuccess(response, 'Cannot load current shift');
    return CashierShift.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<CashierShift> openShift({
    required int userId,
    required double initialCash,
    String salesPoint = 'Main Store',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.shiftsPath}/open'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'initialCash': initialCash,
        'salesPoint': salesPoint,
      }),
    );
    _ensureSuccess(response, 'Cannot open shift');
    return CashierShift.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<CashierShift> closeCurrentShift({
    required int userId,
    required double totalCashEnd,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.shiftsPath}/current/$userId/close',
      ),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'totalCashEnd': totalCashEnd}),
    );
    _ensureSuccess(response, 'Cannot close shift');
    return CashierShift.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<CashierShift>> getShiftHistory(int userId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.shiftsPath}/history/$userId',
      ),
    );
    _ensureSuccess(response, 'Cannot load shift history');
    final decoded = jsonDecode(response.body);
    if (decoded is! List) throw Exception('Invalid shift history response');
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CashierShift.fromJson)
        .toList();
  }

  void _ensureSuccess(http.Response response, String fallback) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          throw Exception(decoded['message']);
        }
      } on FormatException {
        // Fall through to the readable fallback below.
      }
    }
    throw Exception(fallback);
  }
}
