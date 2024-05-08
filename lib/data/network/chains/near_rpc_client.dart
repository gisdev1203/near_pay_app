import 'dart:developer';

import 'package:bs58/bs58.dart';
// ignore: depend_on_referenced_packages
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterchain/flutterchain_lib/constants/core/blockchain_response.dart';
import 'package:flutterchain/flutterchain_lib/constants/chains/near_blockchain_network_urls.dart';
import 'package:flutterchain/flutterchain_lib/formaters/chains/near_formater.dart';
import 'package:flutterchain/flutterchain_lib/models/chains/near/near_transaction_info.dart';
import 'package:flutterchain/flutterchain_lib/models/core/blockchain_response.dart';
import 'package:flutterchain/flutterchain_lib/network/core/network_core.dart';
import 'dart:async';
import 'package:hex/hex.dart';

class NearRpcClient {
  final NearNetworkClient networkClient;

  factory NearRpcClient.defaultInstance() {
    return NearRpcClient(
      networkClient: NearNetworkClient(
        baseUrl: NearBlockChainNetworkUrls.listOfUrls.first,
        dio: Dio(),
      ), baseUrl: '', httpClient: null,
    );
  }
  NearRpcClient({required this.networkClient, required String baseUrl, required httpClient});

  Future<NearTransactionInfoModel> getTransactionInfo(
    String accountId,
    String publicKey,
  ) async {
    Uint8List hash = HEX.decode(publicKey) as Uint8List;

    final res = await networkClient.postHTTP('', {
      "jsonrpc": "2.0",
      "id": "dontcare",
      "method": "query",
      "params": {
        "request_type": "view_access_key",
        "finality": "final",
        "account_id": accountId,
        "public_key": "ed25519:${base58.encode(hash)}"
      }
    });
    if (res.isSuccess) {
      final nonce = int.tryParse(res.data['result']['nonce'].toString()) ?? 0;
      final blockHash = res.data['result']['block_hash'].toString();
      return NearTransactionInfoModel(blockHash: blockHash, nonce: nonce);
    } else {
      return NearTransactionInfoModel(blockHash: '', nonce: 0);
    }
  }

  Future<String> getAccountBalance(
    String accountId,
  ) async {
    final res = await networkClient.postHTTP(
      '',
      {
        "jsonrpc": "2.0",
        "id": "dontcare",
        "method": "query",
        "params": {
          "request_type": "view_account",
          "finality": "final",
          "account_id": accountId
        }
      },
    );
    if (res.isSuccess) {
      final decodedRes = res.data['result']['amount'].toString();
      final nearAmount = NearFormatter.yoctoNearToNear(
        decodedRes,
      );
      return nearAmount;
    } else {
      return "Error while getting balance";
    }
  }

  Future<BlockchainResponse> sendAsyncTx(List<String> params) async {
    final res = await networkClient.postHTTP('', {
      "jsonrpc": "2.0",
      "id": "dontcare",
      "method": "broadcast_tx_async",
      "params": params
    });
    if (res.data['error'] != null) {
      return BlockchainResponse(
        data: res.data['error'],
        status: BlockchainResponses.error,
      );
    }

    String? transactionHash = res.data['result']['transaction']['hash'];
    String response = res.data['result']['status']['SuccessValue'] != null
        ? NearFormatter.decodeResultOfResponse(
            res.data['result']['status']['SuccessValue'].toString())
        : "no data in response";
    final String? functionCallError = res.data['result']['status']['Failure']
        ['ActionError']['kind']['FunctionCallError']['ExecutionError'];

    if (res.isSuccess && functionCallError == null) {
      return BlockchainResponse(
        data: {
          "txHash": transactionHash,
          "response": response,
        },
        status: BlockchainResponses.success,
      );
    } else {
      return BlockchainResponse(
        data: {
          "txHash": transactionHash,
          "error": functionCallError,
        },
        status: BlockchainResponses.error,
      );
    }
  }

  Future<BlockchainResponse> sendSyncTx(List<String> params) async {
    final res = await networkClient.postHTTP('', {
      "jsonrpc": "2.0",
      "id": "dontcare",
      "method": "broadcast_tx_commit",
      "params": params
    });
    if (res.data['error'] != null) {
      return BlockchainResponse(
        data: res.data['error'],
        status: BlockchainResponses.error,
      );
    }

    String? transactionHash = res.data['result']['transaction']['hash'];
    String response = res.data['result']['status']['SuccessValue'] != null
        ? NearFormatter.decodeResultOfResponse(
            res.data['result']['status']['SuccessValue'].toString())
        : "no data in response";
    final String? functionCallError = res.data?['result']?['status']?['Failure']
        ?['ActionError']?['kind']?['FunctionCallError']?['ExecutionError'];
    final String? executionError = res.data?['result']?['status']?['Failure']
        ?['ActionError']?['kind']?['FunctionCallError']?['MethodResolveError'];

    if (res.isSuccess && functionCallError == null && executionError == null) {
      return BlockchainResponse(
        data: {
          "txHash": transactionHash,
          "success": response,
        },
        status: BlockchainResponses.success,
      );
    } else {
      return BlockchainResponse(
        data: {
          "txHash": transactionHash,
          "error": functionCallError ?? executionError,
        },
        status: BlockchainResponses.error,
      );
    }
  }
}

class NearNetworkClient extends NetworkClient {
  NearNetworkClient({required super.baseUrl, required super.dio}) {
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: log,
        retries: 5,
        retryDelays: const [
          Duration(seconds: 2),
          Duration(seconds: 1),
          Duration(seconds: 1),
          Duration(seconds: 1),
          Duration(seconds: 1),
        ],
      ),
    );
  }
}
class BlockchainClient {
  final BlockchainNetworkClient networkClient;

  factory BlockchainClient.defaultInstance() {
    return BlockchainClient(
      networkClient: BlockchainNetworkClient(
        baseUrl: NearBlockChainNetworkUrls.listOfUrls.first,
        dio: Dio(),
      ),
    );
  }

  BlockchainClient({required this.networkClient});

  Future<NearTransactionInfoModel> getTransactionInfo(
    String accountId,
    String publicKey,
  ) async {
    Uint8List hash = HEX.decode(publicKey) as Uint8List;

    final res = await networkClient.postHTTP('', {
      "jsonrpc": "2.0",
      "id": "dontcare",
      "method": "query",
      "params": {
        "request_type": "view_access_key",
        "finality": "final",
        "account_id": accountId,
        "public_key": "ed25519:${base58.encode(hash)}"
      }
    });
    if (res.isSuccess) {
      final nonce = int.tryParse(res.data['result']['nonce'].toString()) ?? 0;
      final blockHash = res.data['result']['block_hash'].toString();
      return NearTransactionInfoModel(blockHash: blockHash, nonce: nonce);
    } else {
      return NearTransactionInfoModel(blockHash: '', nonce: 0);
    }
  }
   Future<BlockchainResponse> deployContract(String contractCode, Map<String, dynamic> args) async {
    try {
      // Your implementation for deploying a smart contract goes here
      // Example: Compile contract code, estimate gas, sign transactions, etc.
      
      // Simulating success for demonstration purposes
      return BlockchainResponse(
        data: {"contractId": "example_contract_id"},
        status: BlockchainResponses.success,
      );
    } catch (e) {
      // Handle any errors during contract deployment
      return BlockchainResponse(
        data: {"error": e.toString()},
        status: BlockchainResponses.error,
      );
    }
  }

  Future<BlockchainResponse> callContractFunction(String contractId, String functionName, List<dynamic> args) async {
    try {
      // Your implementation for calling a function on a smart contract goes here
      // Example: Encode function calls, manage nonce, estimate gas, etc.

      // Simulating success for demonstration purposes
      return BlockchainResponse(
        data: {"result": "example_result"},
        status: BlockchainResponses.success,
      );
    } catch (e) {
      // Handle any errors during contract function call
      return BlockchainResponse(
        data: {"error": e.toString()},
        status: BlockchainResponses.error,
      );
    }
  }

  Future<void> monitorContractEvents(String contractId, void Function(Map<String, dynamic>) callback) async {
    try {
      // Your implementation for monitoring events emitted by a smart contract goes here
      // Example: Set up WebSocket connections, filter events, etc.
      
      // Simulating event monitoring for demonstration purposes
      final eventData = {"event": "example_event"};
      callback(eventData);
    } catch (e) {
      // Handle any errors during event monitoring
      if (kDebugMode) {
        print("Error in monitoring contract events: $e");
      }
    }
  }

  Future<String> getAccountBalance(
    String accountId,
  ) async {
    final res = await networkClient.postHTTP(
      '',
      {
        "jsonrpc": "2.0",
        "id": "dontcare",
        "method": "query",
        "params": {
          "request_type": "view_account",
          "finality": "final",
          "account_id": accountId
        }
      },
    );
    if (res.isSuccess) {
      final decodedRes = res.data['result']['amount'].toString();
      final nearAmount = NearFormatter.yoctoNearToNear(
        decodedRes,
      );
      return nearAmount;
    } else {
      return "Error while getting balance";
    }
  }

  Future<BlockchainResponse> sendAsyncTx(List<String> params) async {
    final res = await networkClient.postHTTP('', {
      "jsonrpc": "2.0",
      "id": "dontcare",
      "method": "broadcast_tx_async",
      "params": params
    });
    if (res.data['error'] != null) {
      return BlockchainResponse(
        data: res.data['error'],
        status: BlockchainResponses.error,
      );
    }

    String? transactionHash = res.data['result']['transaction']['hash'];
    String response = res.data['result']['status']['SuccessValue'] != null
        ? NearFormatter.decodeResultOfResponse(
            res.data['result']['status']['SuccessValue'].toString())
        : "no data in response";
    final String? functionCallError = res.data['result']['status']['Failure']
        ['ActionError']['kind']['FunctionCallError']['ExecutionError'];

    if (res.isSuccess && functionCallError == null) {
      return BlockchainResponse(
        data: {
          "txHash": transactionHash,
          "response": response,
        },
        status: BlockchainResponses.success,
      );
    } else {
      return BlockchainResponse(
        data: {
          "txHash": transactionHash,
          "error": functionCallError,
        },
        status: BlockchainResponses.error,
      );
    }
  }

  Future<BlockchainResponse> sendSyncTx(List<String> params) async {
    final res = await networkClient.postHTTP('', {
      "jsonrpc": "2.0",
      "id": "dontcare",
      "method": "broadcast_tx_commit",
      "params": params
    });
    if (res.data['error'] != null) {
      return BlockchainResponse(
        data: res.data['error'],
        status: BlockchainResponses.error,
      );
    }

    String? transactionHash = res.data['result']['transaction']['hash'];
    String response = res.data['result']['status']['SuccessValue'] != null
        ? NearFormatter.decodeResultOfResponse(
            res.data['result']['status']['SuccessValue'].toString())
        : "no data in response";
    final String? functionCallError = res.data?['result']?['status']?['Failure']
        ?['ActionError']?['kind']?['FunctionCallError']?['ExecutionError'];
    final String? executionError = res.data?['result']?['status']?['Failure']
        ?['ActionError']?['kind']?['FunctionCallError']?['MethodResolveError'];

    if (res.isSuccess && functionCallError == null && executionError == null) {
      return BlockchainResponse(
        data: {
          "txHash": transactionHash,
          "success": response,
        },
        status: BlockchainResponses.success,
      );
    } else {
      return BlockchainResponse(
        data: {
          "txHash": transactionHash,
          "error": functionCallError ?? executionError,
        },
        status: BlockchainResponses.error,
      );
    }
  }
}

class BlockchainNetworkClient extends NetworkClient {
  BlockchainNetworkClient({required super.baseUrl, required super.dio}) {
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: log,
        retries: 5,
        retryDelays: const [
          Duration(seconds: 2),
          Duration(seconds: 1),
          Duration(seconds: 1),
          Duration(seconds: 1),
          Duration(seconds: 1),
        ],
      ),
    );
  }
}