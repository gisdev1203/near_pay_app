import 'package:http/http.dart' as http;

class Near {
  final String baseUrl;

  Near(this.baseUrl);

  Future<String> getBlockchainInfo() async {
    final response = await http.get(Uri.parse('$baseUrl/blockchain'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load blockchain info');
    }
  }

  Future<void> sendTransaction(String transactionData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      body: transactionData,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send transaction');
    }
  }

  Future<String> getAccountBalance(String accountId) async {
    final response = await http.get(Uri.parse('$baseUrl/accounts/$accountId/balance'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load account balance');
    }
  }
}
