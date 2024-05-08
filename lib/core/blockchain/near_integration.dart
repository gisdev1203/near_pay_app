// ignore_for_file: library_private_types_in_public_api, unused_import
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:near_pay_app/models/chains/near/near_blockchain_data.dart';
import 'package:near_pay_app/network/chains/near_rpc_client.dart';

class NearIntegration extends StatefulWidget {
  const NearIntegration({super.key});

  @override
  _NearIntegrationState createState() => _NearIntegrationState();
}

class _NearIntegrationState extends State<NearIntegration> {
  late final NearRpcClient _rpcClient;
  late final TextEditingController _accountIdController;
  NearBlockChainData? _blockchainData; // Make this nullable

  @override
  void initState() {
    super.initState();
    _rpcClient = NearRpcClient('https://rpc.testnet.near.org', httpClient: http.Client(), networkClient: null, baseUrl: '');

    _accountIdController = TextEditingController();
    _blockchainData = null; // Initialize as null
  }

  @override
  void dispose() {
    _accountIdController.dispose();
    super.dispose();
  }

  Future<void> fetchBlockchainData() async {
    try {
      final blockchainData = await _rpcClient.getBlockchainData(_accountIdController.text);
      setState(() {
        _blockchainData = blockchainData;
      });
    } catch (e) {
      // Handle the error appropriately
      if (kDebugMode) {
        print(e);
      } // Consider showing an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Near Integration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _accountIdController,
              decoration: const InputDecoration(labelText: 'Enter Account ID'),
            ),
            ElevatedButton(
              onPressed: fetchBlockchainData, // Corrected to call fetchBlockchainData
              child: const Text('Fetch Blockchain Data'),
            ),
            const SizedBox(height: 20),
            const Text('Blockchain Data Details:'),
            Text('Account ID: ${_blockchainData?.accountId ?? 'N/A'}'), // Use null-aware operators
            Text('Public Key: ${_blockchainData?.publicKey ?? 'N/A'}'),
            Text('Private Key: ${_blockchainData?.privateKey ?? 'N/A'}'),
            Text('Derivation Path: ${_blockchainData?.derivationPath ?? 'N/A'}'),
            Text('Passphrase: ${_blockchainData?.passphrase ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}
class NearRpcClient {
  final String baseUrl;
  final http.Client httpClient;

  NearRpcClient(param0, {required this.baseUrl, required this.httpClient, required networkClient});

  Future<NearBlockChainData> getBlockchainData(String accountId) async {
    var url = Uri.parse('$baseUrl/account/$accountId');
    var response = await httpClient.get(url);
    if (response.statusCode == 200) {
      // Update to match how your NearBlockChainData is constructed
      return NearBlockChainData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch blockchain data');
    }
  }
}