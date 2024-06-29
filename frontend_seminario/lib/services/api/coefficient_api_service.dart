import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class CoefficientApiService extends BaseApiService {
  // Get All Coefficients
  static Future<http.Response> getAllCoefficients() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/coefficients'),
      headers: headers,
    );
  }

  // Create Coefficient
  static Future<http.Response> createCoefficient(Map<String, dynamic> coefficientData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/coefficients'),
      headers: headers,
      body: jsonEncode(coefficientData),
    );
  }

  // Get Coefficient By ID
  static Future<http.Response> getCoefficientById(int coefficientId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/coefficients/$coefficientId'),
      headers: headers,
    );
  }

  // Delete Coefficient
  static Future<http.Response> deleteCoefficient(int coefficientId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/coefficients/$coefficientId'),
      headers: headers,
    );
  }

  // Edit Coefficient
  static Future<http.Response> editCoefficient(int coefficientId, Map<String, dynamic> coefficientData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse('${BaseApiService.baseUrl}/coefficients/$coefficientId'),
      headers: headers,
      body: jsonEncode(coefficientData),
    );
  }
}
