// ignore_for_file: deprecated_member_use

import 'package:json_annotation/json_annotation.dart';
import 'package:near_pay_app/data/network/model/response/pending_response.dart';



part 'account_balance_item.g.dart';

@JsonSerializable()
class AccountBalanceItem {
  @JsonKey(name:"balance")
  String balance;

  @JsonKey(name: "pending")
  String pending;

  @JsonKey(ignore: true)
  String privKey;

  @JsonKey(ignore: true)
  String frontier;

  @JsonKey(ignore: true)
  PendingResponse pendingResponse;

  AccountBalanceItem({required this.balance, required this.pending, required this.privKey, required this.frontier, required this.pendingResponse});

  factory AccountBalanceItem.fromJson(Map<String, dynamic> json) => _$AccountBalanceItemFromJson(json);
  Map<String, dynamic> toJson() => _$AccountBalanceItemToJson(this);
}