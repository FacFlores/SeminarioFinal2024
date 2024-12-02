import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class NotificationsApiService extends BaseApiService {
  // Create a new notification
  static Future<http.Response> createNotification(
      Map<String, dynamic> notificationData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/notifications/'),
      headers: headers,
      body: jsonEncode(notificationData),
    );
  }

  // Mark a notification as read
  static Future<http.Response> markNotificationAsRead(int notificationId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.put(
      Uri.parse('${BaseApiService.baseUrl}/notifications/$notificationId/mark-read'),
      headers: headers,
    );
  }

  // Get notifications for a specific user
  static Future<http.Response> getNotificationsByUser(int userId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/notifications/user/$userId'),
      headers: headers,
    );
  }

  // Get notifications for a specific role
  static Future<http.Response> getNotificationsByRole(String role) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/notifications/role/$role'),
      headers: headers,
    );
  }

  // Get notifications for a specific unit
  static Future<http.Response> getNotificationsByUnit(int unitId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/notifications/unit/$unitId'),
      headers: headers,
    );
  }

  // Get notifications for a specific consortium
  static Future<http.Response> getNotificationsByConsortium(
      int consortiumId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/notifications/consortium/$consortiumId'),
      headers: headers,
    );
  }

  // Delete a notification
  static Future<http.Response> deleteNotification(int notificationId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/notifications/$notificationId'),
      headers: headers,
    );
  }
}
