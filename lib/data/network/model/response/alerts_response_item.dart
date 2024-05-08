import 'package:json_annotation/json_annotation.dart';

part 'alerts_response_item.g.dart';

@JsonSerializable()
class AlertResponseItem {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'active')
  bool active;

  @JsonKey(name: 'priority')
  String priority;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'short_description')
  String shortDescription;

  @JsonKey(name: 'long_description')
  String longDescription;

  @JsonKey(name: 'link')
  String link;

  @JsonKey(name: 'timestamp')
  int timestamp;

  AlertResponseItem({
    required this.id,
    required this.active,
    required this.priority,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.link,
    required this.timestamp,
  });

  factory AlertResponseItem.fromJson(Map<String, dynamic> json) =>
      _$AlertResponseItemFromJson(json);
  Map<String, dynamic> toJson() => _$AlertResponseItemToJson(this);

  @override
  bool operator ==(other) => other is AlertResponseItem && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
