// ignore_for_file: unnecessary_null_comparison, deprecated_member_use, prefer_initializing_formals

import 'package:json_annotation/json_annotation.dart';
import 'package:near_pay_app/core/models/address.dart';
import 'package:near_pay_app/presantation/utils/numberutil.dart';



part 'account_history_response_item.g.dart';

int? _toInt(String v) => v == null ? 0 : int.tryParse(v);

@JsonSerializable()
class AccountHistoryResponseItem {
  @JsonKey(name:'type')
  String type;

  @JsonKey(name:'account')
  String account;

  @JsonKey(name:'amount')
  String amount;

  @JsonKey(name:'hash')
  String hash;

  @JsonKey(name:'height', fromJson: _toInt)
  int height;

  @JsonKey(ignore: true)
  bool confirmed;

  AccountHistoryResponseItem({required String type, required String account, required String amount, required String hash, required int height, required this.confirmed}) {
    this.type = type;
    this.account = account;
    this.amount = amount;
    this.hash = hash;
    this.height = height;
  }

  String? getShortString() {
    return Address(account).getShortString();
  }

  String? getShorterString() {
    return Address(account).getShorterString();
  }

  /// Return amount formatted for use in the UI
  String getFormattedAmount() {
    return NumberUtil.getRawAsUsableString(amount);
  }

  factory AccountHistoryResponseItem.fromJson(Map<String, dynamic> json) => _$AccountHistoryResponseItemFromJson(json);
  Map<String, dynamic> toJson() => _$AccountHistoryResponseItemToJson(this);

  @override
  bool operator ==(other) => other is AccountHistoryResponseItem && other.hash == hash;
  @override
  int get hashCode => hash.hashCode;
}