// ignore_for_file: depend_on_referenced_packages

import 'package:flutterchain/flutterchain_lib/constants/core/supported_blockchains.dart';
import 'package:flutterchain/flutterchain_lib/models/core/wallet.dart';
import 'package:json_annotation/json_annotation.dart';

part 'near_blockchain_data.g.dart';

@JsonSerializable()
class NearBlockChainData extends BlockChainData {
  String? accountId;
  NearBlockChainData({
    this.accountId,
    // Standard near ed25519 public key
    required super.publicKey,
    // Base 64 encoded
    required super.privateKey,
    required super.derivationPath,
    required super.passphrase,
    required super.identifier, // Add the identifier parameter here
  });

  factory NearBlockChainData.fromJson(Map<String, dynamic> json) =>
      _$NearBlockChainDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NearBlockChainDataToJson(this);

  @override
  String toString() {
    return "{publicKey $publicKey , privateKey $privateKey }";

    
  }
}
