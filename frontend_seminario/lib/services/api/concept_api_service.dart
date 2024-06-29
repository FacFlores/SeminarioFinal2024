import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class ConceptApiService extends BaseApiService {
  // Get All Concepts
  static Future<http.Response> getAllConcepts() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/concepts'),
      headers: headers,
    );
  }

  // Create Concept
  static Future<http.Response> createConcept(
      Map<String, dynamic> conceptData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/concepts'),
      headers: headers,
      body: jsonEncode(conceptData),
    );
  }

  // Get Concept By ID
  static Future<http.Response> getConceptById(int conceptId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/concepts/$conceptId'),
      headers: headers,
    );
  }

  // Delete Concept
  static Future<http.Response> deleteConcept(int conceptId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/concepts/$conceptId'),
      headers: headers,
    );
  }

  // Edit Concept
  static Future<http.Response> editConcept(
      int conceptId, Map<String, dynamic> conceptData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse('${BaseApiService.baseUrl}/concepts/$conceptId'),
      headers: headers,
      body: jsonEncode(conceptData),
    );
  }
}