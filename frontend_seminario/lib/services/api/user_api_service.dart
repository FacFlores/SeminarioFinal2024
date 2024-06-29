import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class UserApiService extends BaseApiService {
  // Register User
  static Future<http.Response> registerUser(Map<String, dynamic> userData) async {
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
  }


  // User Login
  static Future<http.Response> loginUser(String email, String password) async {
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  // Get All Users
  static Future<http.Response> getAllUsers() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/users'),
      headers: headers,
    );
  }

  // Get Inactive Users
  static Future<http.Response> getInactiveUsers() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/users/inactive'),
      headers: headers,
    );
  }

  // Get Active Users
  static Future<http.Response> getActiveUsers() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/users/active'),
      headers: headers,
    );
  }
}