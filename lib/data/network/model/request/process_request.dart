// ignore_for_file: unnecessary_this

import 'package:json_annotation/json_annotation.dart';
import 'package:near_pay_app/data/network/model/base_request.dart';
import 'package:near_pay_app/data/network/model/request/actions.dart';


part 'process_request.g.dart';

@JsonSerializable()
class ProcessRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:'block')
  String block;

  // Kalium/Natrium server accepts an optional do_work parameter. If true server will add work to this block for us
  @JsonKey(name:'do_work')
  bool doWork;

  @JsonKey(name: 'subtype')
  String subType;

  ProcessRequest({required this.block, this.doWork = true, required this.subType}) {
    this.action = Actions.PROCESS;
  }

  factory ProcessRequest.fromJson(Map<String, dynamic> json) => _$ProcessRequestFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ProcessRequestToJson(this);
}