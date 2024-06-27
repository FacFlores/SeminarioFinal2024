import 'dart:convert';
import 'package:frontend_seminario/utils/config.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = Config.apiUrl;
  static final StorageService storageService = StorageService();

  static Future<http.Response> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final token = responseBody['token'];
      final user = responseBody['user'];
      await storageService.saveToken(token);
      await storageService.saveUserData(user);
    } else {
      print('Failed to login: ${response.statusCode}');
      print('Response: ${response.body}');
    }

    return response;
  }

  static Future<http.Response> register(String name, String email,
      String password, String surname, String phone, String dni) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
        'surname': surname,
        'phone': phone,
        'dni': dni,
      }),
    );
    return response;
  }

  static Future<http.Response> getProtectedResource() async {
    final token = await storageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/protected-endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }
}
