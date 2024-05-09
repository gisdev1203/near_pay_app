import 'package:json_annotation/json_annotation.dart';
import 'package:near_pay_app/data/network/model/base_request.dart';
import 'package:near_pay_app/data/network/model/request/actions.dart';



part 'account_history_request.g.dart';

@JsonSerializable()
class AccountHistoryRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:'account')
  String account;

  @JsonKey(name:'count', includeIfNull: false)
  int count;

  AccountHistoryRequest({required String action, required this.account, required this.count}):super() {
    this.action = Actions.ACCOUNT_HISTORY;
  }

  factory AccountHistoryRequest.fromJson(Map<String, dynamic> json) => _$AccountHistoryRequestFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AccountHistoryRequestToJson(this);
}