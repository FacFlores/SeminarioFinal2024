import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class ReservationsApiService extends BaseApiService {
  // Create a new reservation
  static Future<http.Response> createReservation(Map<String, dynamic> reservationData) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.post(
      Uri.parse('${BaseApiService.baseUrl}/reservations'),
      headers: headers,
      body: jsonEncode(reservationData),
    );
  }

  // Get reservations by consortium (Reservation history for consortium)
  static Future<http.Response> getReservationsByConsortium(int consortiumId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.get(
      Uri.parse('${BaseApiService.baseUrl}/reservations?consortium_id=$consortiumId'),
      headers: headers,
    );
  }

  // Delete a reservation
  static Future<http.Response> deleteReservation(int reservationId) async {
    final headers = await BaseApiService.getCommonHeaders();
    return http.delete(
      Uri.parse('${BaseApiService.baseUrl}/reservations/$reservationId'),
      headers: headers,
    );
  }

  
}
