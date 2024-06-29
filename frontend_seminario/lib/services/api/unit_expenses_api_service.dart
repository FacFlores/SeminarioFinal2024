import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class UnitExpensesApiService extends BaseApiService {
  // Get All Units Expenses
  static Future<http.Response> getAllUnitsExpenses() async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/unit-expenses'),
      headers: headers,
    );
  }

  // Get Units Expenses By Unit ID
  static Future<http.Response> getUnitsExpensesByUnit(int unitId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/unit-expenses/$unitId'),
      headers: headers,
    );
  }

  // Create Unit Expense
  static Future<http.Response> createUnitExpense(
      Map<String, dynamic> expenseData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/unit-expenses'),
      headers: headers,
      body: jsonEncode(expenseData),
    );
  }

  // Get Unit Expense Status By ID
  static Future<http.Response> getUnitExpenseStatus(int expenseId,
      {required bool liquidated, required bool paid}) async {
    final headers = await BaseApiService.getCommonHeaders();
    final queryParameters = {
      'liquidated': liquidated.toString(),
      'paid': paid.toString(),
    };
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/unit-expenses/status/$expenseId')
          .replace(queryParameters: queryParameters),
      headers: headers,
    );
  }

  // Delete Unit Expense in DB
  static Future<http.Response> deleteUnitExpense(int expenseId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/unit-expenses/$expenseId'),
      headers: headers,
    );
  }

  // Edit Unit Expense By ID
  static Future<http.Response> editUnitExpense(
      int expenseId, Map<String, dynamic> updatedData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse('${BaseApiService.baseUrl}/unit-expenses/$expenseId'),
      headers: headers,
      body: jsonEncode(updatedData),
    );
  }
}
