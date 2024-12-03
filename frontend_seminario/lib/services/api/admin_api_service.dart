import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class AdminApiService {
  static Future<http.Response> adminLogin(String email, String password) async {
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  static Future<http.Response> registerAdmin(Map<String, dynamic> adminData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/admin/register'),
      headers: headers,
      body: jsonEncode(adminData),
    );
  }

  static Future<http.Response> toggleUserStatus(int userId, Map<String, dynamic> userData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse('${BaseApiService.baseUrl}/admin/toggle-user-status/$userId'),
      headers: headers,
      body: jsonEncode(userData),
    );
  }

  static Future<http.Response> deleteUser(int userId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/admin/users/$userId'),
      headers: headers,
    );
  }

  static Future<http.Response> getAllAdmins() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/admin'),
      headers: headers,
    );
  }
}
