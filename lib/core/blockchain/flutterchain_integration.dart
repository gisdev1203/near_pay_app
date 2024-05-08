// ignore_for_file: library_private_types_in_public_api
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutterchain/flutterchain_lib/models/core/wallet.dart';
import 'package:near_pay_app/blockchain/blockchain_wallet_service.dart';


class FlutterchainIntegration extends StatefulWidget {
  const FlutterchainIntegration({super.key});

  @override
  _FlutterchainIntegrationState createState() => _FlutterchainIntegrationState();
}

class _FlutterchainIntegrationState extends State<FlutterchainIntegration> {
  late final BlockchainWalletService _walletService;
  late final TextEditingController _walletIdController;
  late final TextEditingController _amountController;
  late Wallet _wallet;

  @override
  void initState() {
    super.initState();
    _walletService = BlockchainWalletService(baseUrl: 'https://rpc.mainnet.near.org', httpClient: http.Client());
    _walletIdController = TextEditingController();
    _amountController = TextEditingController();
    _wallet = Wallet(id: '', name: '', mnemonic: '', passphrase: null, blockchainsData: null);
  }

  @override
  void dispose() {
    _walletIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchWallet() async {
    try {
      final walletId = _walletIdController.text;
      final wallet = await _walletService.getWallet(walletId);
      setState(() {
        _wallet = wallet;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _transferFunds() async {
    try {
      final amount = double.parse(_amountController.text);
      await _walletService.transfer(_wallet.id, 'recipient_wallet_id', amount);
      // Funds transferred successfully
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutterchain Integration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _walletIdController,
              decoration: const InputDecoration(labelText: 'Enter Wallet ID'),
            ),
            ElevatedButton(
              onPressed: _fetchWallet,
              child: const Text('Fetch Wallet'),
            ),
            const SizedBox(height: 20),
            const Text('Wallet Details:'),
            Text('ID: ${_wallet.id}'),
            Text('Name: ${_wallet.name}'),
            Text('Mnemonic: ${_wallet.mnemonic}'),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter Amount to Transfer'),
            ),
            ElevatedButton(
              onPressed: _transferFunds,
              child: const Text('Transfer Funds'),
            ),
          ],
        ),
      ),
    );
  }
}
