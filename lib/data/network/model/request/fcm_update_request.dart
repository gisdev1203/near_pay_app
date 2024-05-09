import 'package:json_annotation/json_annotation.dart';
import 'package:near_pay_app/data/network/model/base_request.dart';
import 'package:near_pay_app/data/network/model/request/actions.dart';

part 'fcm_update_request.g.dart';

@JsonSerializable()
class FcmUpdateRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:'account', includeIfNull: false)
  String account;

  @JsonKey(name:'fcm_token_v2', includeIfNull: false)
  String fcmToken;

  @JsonKey(name:'enabled')
  bool enabled;

  FcmUpdateRequest({required this.account, required this.fcmToken, required this.enabled}) : super() {
    action = Actions.FCM_UPDATE;
  }

  factory FcmUpdateRequest.fromJson(Map<String, dynamic> json) => _$FcmUpdateRequestFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FcmUpdateRequestToJson(this);
}