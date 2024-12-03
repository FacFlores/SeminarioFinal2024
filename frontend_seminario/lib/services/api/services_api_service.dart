import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class ServicesApiService extends BaseApiService {
  // Create a new service
  static Future<http.Response> createService(Map<String, dynamic> serviceData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/services/'),
      headers: headers,
      body: jsonEncode(serviceData),
    );
  }

  // Update an existing service
  static Future<http.Response> updateService(int serviceId, Map<String, dynamic> serviceData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse('${BaseApiService.baseUrl}/services/$serviceId'),
      headers: headers,
      body: jsonEncode(serviceData),
    );
  }

  // Get services by consortium
  static Future<http.Response> getServicesByConsortium(int consortiumId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/services/consortium/$consortiumId'),
      headers: headers,
    );
  }

  // Get all services
  static Future<http.Response> getAllServices() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/services'),
      headers: headers,
    );
  }

  // Delete a service
  static Future<http.Response> deleteService(int serviceId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/services/$serviceId'),
      headers: headers,
    );
  }
}
