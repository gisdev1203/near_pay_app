import 'package:flutterchain/flutterchain_lib/constants/core/supported_blockchains.dart';
import 'package:flutterchain/flutterchain_lib/models/core/wallet.dart';


import '../services/contract_service.dart';

class ContractRepository {
  final ContractService _contractService;

  ContractRepository(this._contractService);

  Future<void> executeContractMethod({
    required Wallet wallet,
    required String contractAddress,
    required String methodName,
    required Map<String, dynamic> params,
  }) async {
    try {
      // Check if the blockchain is supported
      if (wallet.blockchainsData != null &&
          wallet.blockchainsData!.containsKey(BlockChains.near)) {
        // Get NEAR contract service from wallet data
        final nearContractService =
            _contractService.getContractService(BlockChains.near);
        // Execute contract method on NEAR blockchain
        await nearContractService.executeContractMethod(
          contractAddress: contractAddress,
          methodName: methodName,
          params: params,
          privateKey: wallet.blockchainsData![BlockChains.near]!.first.privateKey,
        );
        // Handle successful contract execution
      } else {
        throw Exception('NEAR blockchain data not found in wallet');
      }
    } catch (e) {
      // Handle contract execution error
      throw Exception('Failed to execute contract method: $e');
    }
  }

  // Additional methods for interacting with smart contracts (e.g., deploy contract, read contract state) can be added here
}
