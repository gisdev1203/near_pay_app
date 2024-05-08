import 'package:dio/dio.dart';

class HTTPClient {
  final Dio _dio = Dio();

  HTTPClient() {
    _dio.options.connectTimeout = 5000 as Duration?; // 5 seconds
    _dio.options.receiveTimeout = 3000 as Duration?; // 3 seconds
  }

  Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw 'Failed to make GET request: $e';
    }
  }

  Future<Response> post(String url, dynamic data) async {
    try {
      final response = await _dio.post(url, data: data);
      return response;
    } catch (e) {
      throw 'Failed to make POST request: $e';
    }
  }

  Future<Response> put(String url, dynamic data) async {
    try {
      final response = await _dio.put(url, data: data);
      return response;
    } catch (e) {
      throw 'Failed to make PUT request: $e';
    }
  }

  Future<Response> delete(String url) async {
    try {
      final response = await _dio.delete(url);
      return response;
    } catch (e) {
      throw 'Failed to make DELETE request: $e';
    }
  }

  // Additional methods for other types of requests (e.g., PATCH, HEAD) can be added here

  void setAuthorizationHeader(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
}
