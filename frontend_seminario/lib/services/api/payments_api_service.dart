import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class PaymentsApiService extends BaseApiService {
  // Pay for a unit expense
  static Future<http.Response> payUnitExpense(int unitExpenseId, double amount, String description) async {
    final headers = await BaseApiService.getCommonHeaders();
    final body = jsonEncode({
      'amount': amount,
      'description': description
    });

    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/unit-expenses/$unitExpenseId/pay'),
      headers: headers,
      body: body
    );
  }
}
