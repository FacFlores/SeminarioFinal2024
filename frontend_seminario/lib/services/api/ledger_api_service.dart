import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class LedgerApiService extends BaseApiService {
  // Create a transaction in the ledger
  static Future<http.Response> createTransaction(
      Map<String, dynamic> transactionData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/ledger/transaction'),
      headers: headers,
      body: jsonEncode(transactionData),
    );
  }

  // Get the balance for a specific unit
  static Future<http.Response> getUnitBalance(int unitId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/ledger/balance/$unitId'),
      headers: headers,
    );
  }

  // Get transactions for a specific unit
  static Future<http.Response> getUnitTransactions(int unitId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/ledger/transactions/$unitId'),
      headers: headers,
    );
  }
}
