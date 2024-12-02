import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:frontend_seminario/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';
import 'dart:html' as html;

class DocumentApiService extends BaseApiService {
  static Future<http.Response> getAllDocuments() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/documents'),
      headers: headers,
    );
  }

  static Future<http.Response> getDocumentByName(String documentName) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/documents/name/$documentName'),
      headers: headers,
    );
  }

  static Future<http.Response> getDocumentsByConsortiumId(
      int consortiumId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/documents/consortium/$consortiumId'),
      headers: headers,
    );
  }

  static Future<http.Response> getDocumentsByUnitId(int unitId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/documents/unit/$unitId'),
      headers: headers,
    );
  }

  static Future<http.Response> uploadDocument(
    String name,
    String? unitId,
    String? consortiumId,
    PlatformFile file,
  ) async {
    final uri = Uri.parse('${BaseApiService.baseUrl}/documents/upload');
    final token = await StorageService().getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    };

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields['name'] = name
      ..fields['document_type'] = "application/pdf";

    if (unitId != null) {
      request.fields['unit_id'] = unitId;
    }
    if (consortiumId != null) {
      request.fields['consortium_id'] = consortiumId;
    }

    if (file.bytes != null) {
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
      );
      request.files.add(multipartFile);
    }

    try {
      var response = await request.send();
      return await http.Response.fromStream(response);
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  static Future<http.Response> deleteDocument(int documentId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/documents/$documentId'),
      headers: headers,
    );
  }

  static Future<http.Response> serveDocument(int documentId) async {
    final headers = await BaseApiService.getCommonHeaders();
    final uri = Uri.parse('${BaseApiService.baseUrl}/documents/$documentId');

    return http.get(uri, headers: headers);
  }
}
