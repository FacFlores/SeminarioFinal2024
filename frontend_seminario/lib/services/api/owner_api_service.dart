import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class OwnersApiService extends BaseApiService {
  // Get All Owners
  static Future<http.Response> getAllOwners() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/owners'),
      headers: headers,
    );
  }

  // Create Owner
  static Future<http.Response> createOwner(
      Map<String, dynamic> ownerData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/owners'),
      headers: headers,
      body: jsonEncode(ownerData),
    );
  }

  // Get Owner By ID
  static Future<http.Response> getOwnerById(int ownerId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/owners/$ownerId'),
      headers: headers,
    );
  }

  // Assign User to Owner
  static Future<http.Response> assignUserToOwner(
      int ownerId, int userId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse(
          '${BaseApiService.baseUrl}/owners/assign-user/$ownerId/$userId'),
      headers: headers,
    );
  }

  // Delete Owner
  static Future<http.Response> deleteOwner(int ownerId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/owners/$ownerId'),
      headers: headers,
    );
  }

  // Get Owner By Name
  static Future<http.Response> getOwnerByName(String name) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/owners/name'),
      headers: headers,
      body: jsonEncode({'name': name}),
    );
  }

  // Edit Owner
  static Future<http.Response> editOwner(
      int ownerId, Map<String, dynamic> ownerData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse('${BaseApiService.baseUrl}/owners/$ownerId'),
      headers: headers,
      body: jsonEncode(ownerData),
    );
  }
}
