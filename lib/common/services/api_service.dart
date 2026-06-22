import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiResult {
  final bool success;
  final dynamic data;
  final String message;

  const ApiResult({required this.success, this.data, this.message = ''});
}

class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  ApiService._();

  Future<ApiResult> login({
    required String baseUrl,
    required String username,
    required String password,
    required String deviceDate,
    required String deviceId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${AppConfig.loginEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'device_date': deviceDate,
              'device_id': deviceId,
              'version': AppConfig.version,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final json = jsonDecode(response.body);
      if (json['status'] == true) {
        return ApiResult(success: true, data: json['data']);
      }
      return ApiResult(success: false, message: json['msg'] ?? 'Login failed');
    } catch (e) {
      return ApiResult(success: false, message: 'Network error: ${e.toString()}');
    }
  }

  Future<ApiResult> verifyQRCode({
    required String baseUrl,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${AppConfig.qrcodeVerifyEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      final json = jsonDecode(response.body);
      if (json['status'] == true) {
        return ApiResult(success: true, data: json['data']);
      }
      return ApiResult(success: false, message: json['msg'] ?? 'Verification failed');
    } catch (e) {
      return ApiResult(success: false, message: 'Network error: ${e.toString()}');
    }
  }

  Future<ApiResult> startAttendance({
    required String baseUrl,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${AppConfig.startAttendanceEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      final json = jsonDecode(response.body);
      if (json['status'] == true) {
        return ApiResult(success: true, data: json['data']);
      }
      return ApiResult(success: false, message: json['msg'] ?? 'Failed to start attendance');
    } catch (e) {
      return ApiResult(success: false, message: 'Network error: ${e.toString()}');
    }
  }
}
