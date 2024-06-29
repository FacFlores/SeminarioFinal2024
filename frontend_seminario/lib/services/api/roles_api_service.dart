import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class RolesApiService extends BaseApiService {
  // Get All Roles
  static Future<http.Response> getAllRoles() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/roles'),
      headers: headers,
    );
  }

  // Create Role
  static Future<http.Response> createRole(Map<String, dynamic> roleData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/roles'),
      headers: headers,
      body: jsonEncode(roleData),
    );
  }

  // Delete Role
  static Future<http.Response> deleteRole(int roleId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/roles/$roleId'),
      headers: headers,
    );
  }

  // Get Role By ID
  static Future<http.Response> getRoleById(int roleId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/roles/$roleId'),
      headers: headers,
    );
  }

  // Get Roles By Name
  static Future<http.Response> getRolesByName(String name) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/roles/name'),
      headers: headers,
      body: jsonEncode({'name': name}),
    );
  }
}
