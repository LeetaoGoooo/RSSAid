import 'dart:ffi';

import 'package:json_annotation/json_annotation.dart';

part 'rule.g.dart';

@JsonSerializable()
class Rule{
  final String title;
  final String docs;
  final List<String> source;
  final dynamic target;

  Rule({
    required this.title,
    required this.docs,
    required this.source,
    required this.target,
  });

  factory Rule.fromJson(Map<String,dynamic> json) => _$RuleFromJson(json);

  Map<String, dynamic> toJson() => _$RuleToJson(this);
}