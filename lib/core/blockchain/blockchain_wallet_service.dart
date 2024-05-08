import 'dart:convert';

import 'package:flutterchain/flutterchain_lib/models/core/wallet.dart';
import 'package:http/http.dart' as http;

class BlockchainWalletService {
  final String baseUrl;
  final http.Client httpClient;

  BlockchainWalletService({
    required this.baseUrl,
    required this.httpClient,
  });

  Future<String> createWallet(String blockchain) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/wallets'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'blockchain': blockchain,
      }),
    );

    if (response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception('Failed to create wallet');
    }
  }

  Future<Wallet> getWallet(String walletId) async {
    final response = await httpClient.get(Uri.parse('$baseUrl/wallets/$walletId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Wallet.fromJson(data);
    } else {
      throw Exception('Failed to get wallet');
    }
  }

  Future<void> deleteWallet(String walletId) async {
    final response = await httpClient.delete(Uri.parse('$baseUrl/wallets/$walletId'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete wallet');
    }
  }

  Future<void> transfer(String fromWalletId, String toWalletId, double amount) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/transactions'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'from': fromWalletId,
        'to': toWalletId,
        'amount': amount,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to transfer funds');
    }
  }
}
