import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:jwt_decoder/jwt_decoder.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    try {
      if (kIsWeb) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
      } else {
        await _secureStorage.write(key: 'auth_token', value: token);
      }
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      if (kIsWeb) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        return prefs.getString('auth_token');
      } else {
        return await _secureStorage.read(key: 'auth_token');
      }
    } catch (e) {
      print('Error retrieving token: $e');
      return null;
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final userJson = jsonEncode(userData);
      if (kIsWeb) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', userJson);
      } else {
        await _secureStorage.write(key: 'user_data', value: userJson);
      }
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      String? userJson;
      if (kIsWeb) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        userJson = prefs.getString('user_data');
      } else {
        userJson = await _secureStorage.read(key: 'user_data');
      }
      if (userJson != null) {
        return jsonDecode(userJson);
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
    return null;
  }

  Future<void> deleteToken() async {
    try {
      if (kIsWeb) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_data');
      } else {
        await _secureStorage.delete(key: 'auth_token');
        await _secureStorage.delete(key: 'user_data');
      }
    } catch (e) {
      print('Error deleting token and user data: $e');
    }
  }

  Future<void> logout() async {
    await deleteToken();
  }

  Future<bool> checkTokenValidity() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      bool isExpired = JwtDecoder.isExpired(token);
      return !isExpired;
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }
}
