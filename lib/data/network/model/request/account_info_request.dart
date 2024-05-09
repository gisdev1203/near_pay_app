import 'package:json_annotation/json_annotation.dart';
import 'package:near_pay_app/data/network/model/base_request.dart';
import 'package:near_pay_app/data/network/model/request/actions.dart';


part 'account_info_request.g.dart';

@JsonSerializable()
class AccountInfoRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:'account')
  String account;


  AccountInfoRequest({required String action, required this.account}):super() {
    this.action = Actions.INFO;
  }

  factory AccountInfoRequest.fromJson(Map<String, dynamic> json) => _$AccountInfoRequestFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AccountInfoRequestToJson(this);
}