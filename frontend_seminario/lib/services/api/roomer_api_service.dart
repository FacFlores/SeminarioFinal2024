import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class RoomerApiService extends BaseApiService {
  // Get All Roomers
  static Future<http.Response> getAllRoomers() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/roomers'),
      headers: headers,
    );
  }

  // Create Roomer
  static Future<http.Response> createRoomer(
      Map<String, dynamic> roomerData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/roomers'),
      headers: headers,
      body: jsonEncode(roomerData),
    );
  }

  // Get Roomer By ID
  static Future<http.Response> getRoomerById(int roomerId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/roomers/$roomerId'),
      headers: headers,
    );
  }

  // Get Roomer By Name
  static Future<http.Response> getRoomerByName(String name) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/roomers/name'),
      headers: headers,
      body: jsonEncode({'name': name}),
    );
  }

  // Edit Roomer
  static Future<http.Response> editRoomer(
      int roomerId, Map<String, dynamic> roomerData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse('${BaseApiService.baseUrl}/roomers/$roomerId'),
      headers: headers,
      body: jsonEncode(roomerData),
    );
  }

  // Delete Roomer
  static Future<http.Response> deleteRoomer(int roomerId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/roomers/$roomerId'),
      headers: headers,
    );
  }

  // Assign User to Roomer
  static Future<http.Response> assignUserToRoomer(
      int roomerId, int userId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse(
          '${BaseApiService.baseUrl}/roomers/assign-user/$roomerId/$userId'),
      headers: headers,
    );
  }
}
