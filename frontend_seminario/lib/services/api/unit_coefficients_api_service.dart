import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class UnitCoefficientsApiService extends BaseApiService {
  // Create Units Coefficients
  static Future<http.Response> createUnitsCoefficients(
      Map<String, dynamic> coefficientsData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/unit-coefficients'),
      headers: headers,
      body: jsonEncode(coefficientsData),
    );
  }

  //Get Units & Coefficients by consortium and coefficient
  static Future<http.Response> getUnitsWithCoefficients(
      Map<String, dynamic> coefficientsData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse(
          '${BaseApiService.baseUrl}/consortiums/units-with-coefficients'),
      headers: headers,
      body: jsonEncode(coefficientsData),
    );
  }
}
