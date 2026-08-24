import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/login_result.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class AuthApiService {
  Future<LoginResult> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginPath}');
    late final http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': emailOrUsername, 'password': password}),
      );
    } catch (_) {
      throw Exception(
        'Cannot connect to server at ${ApiConstants.baseUrl}. '
        'If running on a real phone, start app with '
        '--dart-define=API_BASE_URL=http://<YOUR_PC_LAN_IP>:8080',
      );
    }

    if (response.body.isEmpty) {
      throw Exception('Empty server response');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    final result = LoginResult.fromJson(json);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return result;
    }

    throw Exception(result.message);
  }

  Future<String> forgotPassword(String email) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.forgotPasswordPath}?email=${Uri.encodeComponent(email)}',
    );
    final response = await http.post(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    } else {
      String errorMessage = response.body;
      if (errorMessage.startsWith('Error: ')) {
        errorMessage = errorMessage.replaceFirst('Error: ', '');
      }
      if (errorMessage.isEmpty) {
        errorMessage = 'Failed to send OTP (Status: ${response.statusCode})';
      }
      throw errorMessage;
    }
  }

  Future<String> verifyOtp(String otp) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.verifyOtpPath}?otp=${Uri.encodeComponent(otp)}',
    );
    final response = await http.post(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    } else {
      String errorMessage = response.body;
      if (errorMessage.startsWith('Error: ')) {
        errorMessage = errorMessage.replaceFirst('Error: ', '');
      }
      if (errorMessage.isEmpty) {
        errorMessage = 'Invalid OTP (Status: ${response.statusCode})';
      }
      throw errorMessage;
    }
  }

  Future<String> resetPassword({
    required String otp,
    required String newPassword,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.resetPasswordPath}?otp=${Uri.encodeComponent(otp)}&newPassword=${Uri.encodeComponent(newPassword)}',
    );
    final response = await http.post(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    } else {
      String errorMessage = response.body;
      if (errorMessage.startsWith('Error: ')) {
        errorMessage = errorMessage.replaceFirst('Error: ', '');
      }
      if (errorMessage.isEmpty) {
        errorMessage =
            'Failed to reset password (Status: ${response.statusCode})';
      }
      throw errorMessage;
    }
  }
}
