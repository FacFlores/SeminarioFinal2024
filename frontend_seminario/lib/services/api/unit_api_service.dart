import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class UnitApiService extends BaseApiService {
  // Get All Units
  static Future<http.Response> getAllUnits() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/units'),
      headers: headers,
    );
  }

  // Create Unit
  static Future<http.Response> createUnit(Map<String, dynamic> unitData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/units'),
      headers: headers,
      body: jsonEncode(unitData),
    );
  }

  // Get Unit By ID
  static Future<http.Response> getUnitById(int unitId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/units/$unitId'),
      headers: headers,
    );
  }

  // Get Units By Consortium
  static Future<http.Response> getUnitsByConsortium(int consortiumId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/units/consortium/$consortiumId'),
      headers: headers,
    );
  }

  // Delete Unit
  static Future<http.Response> deleteUnit(int unitId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/units/$unitId'),
      headers: headers,
    );
  }

  // Get Unit By Name
  static Future<http.Response> getUnitByName(String name) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/units/name'),
      headers: headers,
      body: jsonEncode({'name': name}),
    );
  }

  // Edit Unit
  static Future<http.Response> editUnit(
      int unitId, Map<String, dynamic> unitData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse('${BaseApiService.baseUrl}/units/$unitId'),
      headers: headers,
      body: jsonEncode(unitData),
    );
  }

  // Assign Owner
  static Future<http.Response> assignOwner(int unitId, int ownerId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse(
          '${BaseApiService.baseUrl}/units/assign-owner/$unitId/$ownerId'),
      headers: headers,
    );
  }

  // Remove Owner
  static Future<http.Response> removeOwner(int unitId, int ownerId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse(
          '${BaseApiService.baseUrl}/units/remove-owner/$unitId/$ownerId'),
      headers: headers,
    );
  }

  // Assign Roomer
  static Future<http.Response> assignRoomer(int unitId, int roomerId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse(
          '${BaseApiService.baseUrl}/units/assign-roomer/$unitId/$roomerId'),
      headers: headers,
    );
  }

  // Remove Roomer
  static Future<http.Response> removeRoomer(int unitId, int roomerId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse(
          '${BaseApiService.baseUrl}/units/remove-roomer/$unitId/$roomerId'),
      headers: headers,
    );
  }

  // Get All Units
  static Future<http.Response> getRoomersByUnit(
    int unitId,
  ) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/units/$unitId/roomers'),
      headers: headers,
    );
  }

  // Get All Units
  static Future<http.Response> getOwnersByUnit(int unitId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/units/$unitId/owners'),
      headers: headers,
    );
  }
}
