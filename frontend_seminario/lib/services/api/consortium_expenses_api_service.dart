import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class ConsortiumExpensesApiService extends BaseApiService {
  // Get All Consortium Expenses
  static Future<http.Response> getAllConsortiumExpenses() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/consortium-expenses'),
      headers: headers,
    );
  }

  // Get Distributed Consortium Expenses
  static Future<http.Response> getDistributedConsortiumExpenses() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/consortium-expenses/distributed'),
      headers: headers,
    );
  }

  // Create Consortium Expense
  static Future<http.Response> createConsortiumExpense(
      Map<String, dynamic> expenseData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/consortium-expenses'),
      headers: headers,
      body: jsonEncode(expenseData),
    );
  }

  // Distribute Consortium Expense
  static Future<http.Response> distributeConsortiumExpense(
      int expenseId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse(
          '${BaseApiService.baseUrl}/consortium-expenses/distribute/$expenseId'),
      headers: headers,
    );
  }

  // Get Consortium Expense By ID
  static Future<http.Response> getConsortiumExpenseById(int id) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/consortium-expenses/$id'),
      headers: headers,
    );
  }

  // Delete Consortium Expense
  static Future<http.Response> deleteConsortiumExpense(int id) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/consortium-expenses/$id'),
      headers: headers,
    );
  }

  // Edit Consortium Expense By ID
  static Future<http.Response> editConsortiumExpense(
      int id, Map<String, dynamic> updatedData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse('${BaseApiService.baseUrl}/consortium-expenses/$id'),
      headers: headers,
      body: jsonEncode(updatedData),
    );
  }

  // Get Non-Distributed Consortium Expenses
  static Future<http.Response> getNonDistributedConsortiumExpenses(
      int consortiumId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse(
          '${BaseApiService.baseUrl}/consortium-expenses/non-distributed/$consortiumId'),
      headers: headers,
    );
  }
}
