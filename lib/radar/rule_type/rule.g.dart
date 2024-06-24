// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rule _$RuleFromJson(Map<String, dynamic> json) => Rule(
      title: json['title'] as String,
      docs: json['docs'] as String,
      source:
          (json['source'] as List<dynamic>).map((e) => e as String).toList(),
      target: json['target'],
    );

Map<String, dynamic> _$RuleToJson(Rule instance) => <String, dynamic>{
      'title': instance.title,
      'docs': instance.docs,
      'source': instance.source,
      'target': instance.target,
    };
