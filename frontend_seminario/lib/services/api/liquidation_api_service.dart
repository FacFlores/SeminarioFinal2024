import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class LiquidationApiService extends BaseApiService {
  // Liquidate an expense by ID for a unit
  static Future<http.Response> liquidateExpenseById(int expenseId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse('${BaseApiService.baseUrl}/unit-expenses/liquidate/$expenseId'),
      headers: headers,
    );
  }

  // Liquidate unit expenses by period
  static Future<http.Response> liquidateUnitExpensesByPeriod(
      int unitId, String period) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse(
          '${BaseApiService.baseUrl}/unit-expenses/liquidate-by-period/$unitId?period=$period'),
      headers: headers,
    );
  }

  // Liquidate consortium expenses by period
  static Future<http.Response> liquidateConsortiumExpensesByPeriod(
      int consortiumId, String period) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse(
          '${BaseApiService.baseUrl}/consortium-expenses/liquidate-by-period/$consortiumId?period=$period'),
      headers: headers,
    );
  }
}
