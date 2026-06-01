import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  /// Registers a new user (customer or business)
  Future<bool> signUp(String email, String password, String role) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/signup',
        data: {
          'email': email,
          'password': password,
          'role': role,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      // Handle or log error accordingly
      return false;
    }
  }

  /// Logs in a user and safely secures their JWT locally
  Future<String?> login(String email, String password) async {
      try {
        final response = await apiClient.dio.post(
          '/auth/login',
          data: {
            'username': email,
            'password': password,
          },
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );

        if (response.statusCode == 200 && response.data != null) {
          final token = response.data['access_token'];
          final role = response.data['role']; // <-- Parse out the role string
          
          await apiClient.storage.write(key: 'access_token', value: token);
          return role; // <-- Return the user role ('customer' or 'business')
        }
        return null;
      } catch (e) {
        return null;
      }
  }

  // Inside your API/Auth repository class:
  Future<bool> savePreferences(List<String> categories) async {
    try {
      // FIX: Added .dio before .post to use your configured Dio instance wrapper
      final response = await apiClient.dio.post( 
        '/users/me/preferences', 
        data: {
          'categories': categories,
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error writing preference payload: ${e.toString()}');
      return false;
    }
  }

  /// Clears out the token on logout
  Future<void> logout() async {
    await apiClient.storage.delete(key: 'access_token');
  }
}