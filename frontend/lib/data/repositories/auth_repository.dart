import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

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
  Future<bool> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {
          'username': email, // FastAPI OAuth2 expects 'username' field
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['access_token'];
        await apiClient.storage.write(key: 'access_token', value: token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Clears out the token on logout
  Future<void> logout() async {
    await apiClient.storage.delete(key: 'access_token');
  }
}