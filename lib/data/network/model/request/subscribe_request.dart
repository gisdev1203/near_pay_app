import 'package:json_annotation/json_annotation.dart';
import 'package:near_pay_app/network/model/base_request.dart';
import 'package:near_pay_app/network/model/request/actions.dart';


part 'subscribe_request.g.dart';

@JsonSerializable()
class SubscribeRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:'account', includeIfNull: false)
  String account;

  @JsonKey(name:'currency', includeIfNull: false)
  String currency;

  @JsonKey(name:'uuid', includeIfNull: false)
  String uuid;

  @JsonKey(name:'fcm_token_v2', includeIfNull: false)
  String fcmToken;

  @JsonKey(name:'notification_enabled')
  bool notificationEnabled;

  SubscribeRequest({this.action = Actions.SUBSCRIBE, required this.account, required this.currency, required this.uuid, required this.fcmToken, required this.notificationEnabled}) : super();

  factory SubscribeRequest.fromJson(Map<String, dynamic> json) => _$SubscribeRequestFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SubscribeRequestToJson(this);
}