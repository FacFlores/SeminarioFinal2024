import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class SpacesApiService extends BaseApiService {
  // Create a new space
  static Future<http.Response> createSpace(Map<String, dynamic> spaceData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/spaces'),
      headers: headers,
      body: jsonEncode(spaceData),
    );
  }

  // Update an existing space
  static Future<http.Response> updateSpace(int spaceId, Map<String, dynamic> spaceData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse('${BaseApiService.baseUrl}/spaces/$spaceId'),
      headers: headers,
      body: jsonEncode(spaceData),
    );
  }

  // Get spaces by consortium
  static Future<http.Response> getSpacesByConsortium(int consortiumId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/spaces/consortium/$consortiumId'),
      headers: headers,
    );
  }

  // Delete a space
  static Future<http.Response> deleteSpace(int spaceId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/spaces/$spaceId'),
      headers: headers,
    );
  }
}
