import 'package:json_annotation/json_annotation.dart';

part 'process_response.g.dart';

@JsonSerializable()
class ProcessResponse {
  @JsonKey(name:'hash')
  String hash;

  ProcessResponse({required this.hash});

  factory ProcessResponse.fromJson(Map<String, dynamic> json) => _$ProcessResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProcessResponseToJson(this);
}