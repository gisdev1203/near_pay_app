// ignore_for_file: deprecated_member_use

import 'package:json_annotation/json_annotation.dart';
import 'package:near_pay_app/network/model/response/pending_response_item.dart';



part 'pending_response.g.dart';

/// For running in an isolate, needs to be top-level function
PendingResponse pendingResponseFromJson(Map<dynamic, dynamic> json) {
  return PendingResponse.fromJson(json);
} 

@JsonSerializable()
class PendingResponse {
  @JsonKey(name:"blocks")
  Map<String, PendingResponseItem> blocks;

  @JsonKey(ignore: true)
  String account;

  PendingResponse({required this.blocks});

  factory PendingResponse.fromJson(Map<String, dynamic> json) => _$PendingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PendingResponseToJson(this);
}