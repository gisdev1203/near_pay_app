// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';


part 'contact.g.dart';

@JsonSerializable()
class Contact {
  @JsonKey(ignore:true)
  int id;
  @JsonKey(name:'name')
  String name;
  @JsonKey(name:'address')
  String address;
  @JsonKey(ignore:true)
  String monkeyPath;
  @JsonKey(ignore:true)
  Widget monkeyWidget;
  @JsonKey(ignore:true)
  Widget monkeyWidgetLarge;

  Contact({required this.name, required this.address, required this.monkeyPath, required int id});

  factory Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);
  Map<String, dynamic> toJson() => _$ContactToJson(this);

  @override
  bool operator ==(other) => other is Contact && other.name == name && other.address == address;
  @override
  int get hashCode => hash(name.hashCode, address.hashCode);
}