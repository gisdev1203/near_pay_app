import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FlutterChainClient {
  final String baseUrl;

  FlutterChainClient(this.baseUrl);

  Future<Map<String, dynamic>> fetchBlockchainData(String blockchain) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/blockchain/$blockchain/data'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch blockchain data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      throw Exception('Failed to connect to the server');
    }
  }

  Future<List<String>> fetchSupportedBlockchains() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/blockchains'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((blockchain) => blockchain['name'] as String).toList();
      } else {
        throw Exception('Failed to fetch supported blockchains');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      throw Exception('Failed to connect to the server');
    }
  }

  Future<void> sendTransaction(Map<String, dynamic> transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transaction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transaction),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send transaction');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      throw Exception('Failed to connect to the server');
    }
  }
}
