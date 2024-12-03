import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class ConsortiumApiService extends BaseApiService {
  static Future<http.Response> getAllConsortiums() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/consortiums'),
      headers: headers,
    );
  }

  static Future<http.Response> createConsortium(
      Map<String, dynamic> consortiumData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/consortiums'),
      headers: headers,
      body: jsonEncode(consortiumData),
    );
  }

  static Future<http.Response> getConsortiumById(int consortiumId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/consortiums/$consortiumId'),
      headers: headers,
    );
  }

  static Future<http.Response> getConsortiumByUnit(int unitId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/consortiums/unit/$unitId'),
      headers: headers,
    );
  }

  static Future<http.Response> deleteConsortium(int consortiumId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/consortiums/$consortiumId'),
      headers: headers,
    );
  }

  static Future<http.Response> getConsortiumByName(String name) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/consortiums/name'),
      headers: headers,
      body: jsonEncode({'name': name}),
    );
  }

  static Future<http.Response> editConsortium(
      int consortiumId, Map<String, dynamic> consortiumData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse('${BaseApiService.baseUrl}/consortiums/$consortiumId'),
      headers: headers,
      body: jsonEncode(consortiumData),
    );
  }
}
