import 'package:json_annotation/json_annotation.dart';
import 'package:near_pay_app/network/model/base_request.dart';
import 'package:near_pay_app/network/model/request/actions.dart';


part 'accounts_balances_request.g.dart';

@JsonSerializable()
class AccountsBalancesRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:'accounts')
  List<String> accounts;

  AccountsBalancesRequest({required this.accounts}) {
    action = Actions.ACCOUNTS_BALANCES;
  }

  factory AccountsBalancesRequest.fromJson(Map<String, dynamic> json) => _$AccountsBalancesRequestFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AccountsBalancesRequestToJson(this);
}