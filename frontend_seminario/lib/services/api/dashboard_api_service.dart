import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class DashboardApiService extends BaseApiService {
  static Future<http.Response> getDashboardSummary() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/dashboard/summary'),
      headers: headers,
    );
  }
}
