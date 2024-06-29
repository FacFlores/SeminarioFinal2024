// api/base_api_service.dart
import 'package:frontend_seminario/utils/config.dart';
import 'package:frontend_seminario/services/storage_service.dart';

class BaseApiService {
  static const String baseUrl = Config.apiUrl;
  static final StorageService storageService = StorageService();

  static Future<Map<String, String>> getCommonHeaders() async {
    final token = await StorageService().getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
}
