import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Replace with your machine's local IP if testing on physical devices
  static const String baseUrl = 'http://127.0.0.1:8000';

  ApiClient() : dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    // Inject an interceptor to automatically attach the JWT token to requests
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
}