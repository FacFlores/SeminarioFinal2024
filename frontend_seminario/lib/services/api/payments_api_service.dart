import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class PaymentsApiService extends BaseApiService {
  // Pay for a unit expense
  static Future<http.Response> payUnitExpense(
      int unitExpenseId, Map<String, dynamic> postData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
        Uri.parse('${BaseApiService.baseUrl}/unit-expenses/$unitExpenseId/pay'),
        headers: headers,
        body: jsonEncode(postData));
  }

  // Pay automatic
  static Future<http.Response> automaticPayment(
      Map<String, dynamic> postData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/unit-expenses/auto-pay'),
      headers: headers,
      body: jsonEncode(postData),
    );
  }
}
