import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:urban_tutor/config.dart';
import 'dart:convert';

class AuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Save credentials securely
  static Future<void> saveCredentials({
    required String username,
    required String email, 
    required String password, 
    required String token
  }) async {
    await _secureStorage.write(key: 'user_username', value: username);
    await _secureStorage.write(key: 'user_email', value: email);
    await _secureStorage.write(key: 'user_password', value: password);
    await _secureStorage.write(key: 'user_token', value: token);
  }

  // Retrieve stored credentials
  static Future<Map<String, String?>> getStoredCredentials() async {
    return {
      'username': await _secureStorage.read(key: 'user_username'),
      'email': await _secureStorage.read(key: 'user_email'),
      'password': await _secureStorage.read(key: 'user_password'),
      'token': await _secureStorage.read(key: 'user_token')
    };
  }

  // Validate token locally
  static Future<bool> isTokenValid() async {
    String? token = await _secureStorage.read(key: 'user_token');
    
    if (token == null) return false;
    
    // return !JwtDecoder.isExpired(token);
    return true; // Always return true, removing expiration check
  }

  // Offline login validation
  static Future<bool> offlineLogin(String email, String password) async {
    String? storedEmail = await _secureStorage.read(key: 'user_email');
    String? storedPassword = await _secureStorage.read(key: 'user_password');
    
    return email == storedEmail && password == storedPassword;
  }

  // Online token validation
  static Future<bool> validateTokenOnline(String token) async {
    try {
      var response = await http.post(
        Uri.parse('$url/api/validate-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
      );

      return json.decode(response.body)['valid'] ?? false;
    } catch (e) {
      // Network error, fallback to local validation
      return isTokenValid();
    }
  }

  // Remove all stored credentials
  static Future<void> logout() async {
    await _secureStorage.deleteAll();
  }

  // Get stored token
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'user_token');
  }
}