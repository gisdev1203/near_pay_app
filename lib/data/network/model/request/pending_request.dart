import 'package:json_annotation/json_annotation.dart';
import 'package:near_pay_app/network/model/base_request.dart';
import 'package:near_pay_app/network/model/request/actions.dart';


part 'pending_request.g.dart';

@JsonSerializable()
class PendingRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:"account")
  String account;

  @JsonKey(name:"source")
  bool source;

  @JsonKey(name:"count")
  int count;

  @JsonKey(name:"include_active")
  bool includeActive;

  @JsonKey(name:"threshold", includeIfNull: false)
  String threshold;

  PendingRequest({this.action = Actions.PENDING, required this.account, this.source = true, required this.count, required this.threshold, this.includeActive = true});

  factory PendingRequest.fromJson(Map<String, dynamic> json) => _$PendingRequestFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PendingRequestToJson(this);
}