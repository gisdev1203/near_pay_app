import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();

  factory HttpClient() {
    return _instance;
  }

  HttpClient._internal();

  Future<Map<String, dynamic>> get(String url, {Map<String, String>? headers}) async {
    final response = await http.get(Uri.parse(url), headers: headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> post(String url, {Map<String, String>? headers, dynamic body}) async {
    final response = await http.post(Uri.parse(url), headers: headers, body: json.encode(body));
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> put(String url, {Map<String, String>? headers, dynamic body}) async {
    final response = await http.put(Uri.parse(url), headers: headers, body: json.encode(body));
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> delete(String url, {Map<String, String>? headers}) async {
    final response = await http.delete(Uri.parse(url), headers: headers);
    return _processResponse(response);
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      return json.decode(responseBody);
    } else {
      throw Exception('HTTP request failed with status code $statusCode: $responseBody');
    }
  }
}

void main() async {
  final client = HttpClient();
  const url = 'https://jsonplaceholder.typicode.com/posts/1';

  try {
    final response = await client.get(url);
    if (kDebugMode) {
      print(response);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error: $e');
    }
  }
}
