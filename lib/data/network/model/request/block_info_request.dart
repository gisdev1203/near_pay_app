import 'package:json_annotation/json_annotation.dart';
import 'package:near_pay_app/network/model/base_request.dart';
import 'package:near_pay_app/network/model/request/actions.dart';


part 'block_info_request.g.dart';

@JsonSerializable()
class BlockInfoRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:'hash')
  String hash;

  BlockInfoRequest({required this.hash}) {
    action = Actions.BLOCK_INFO;
  }

  factory BlockInfoRequest.fromJson(Map<String, dynamic> json) => _$BlockInfoRequestFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BlockInfoRequestToJson(this);
}