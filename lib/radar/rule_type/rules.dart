
import 'package:rssaid/radar/rule_type/rule.dart';

class Rules {
  final Map<String, Map<String, dynamic>> _rules;

  Rules(this._rules);

  factory Rules.fromJson(Map<String, dynamic> json) {
    final Map<String, Map<String, dynamic>> rules = {};
    json.forEach((key, value) {
      final Map<String, dynamic> rule = {};
      (value as Map<String, dynamic>).forEach((subKey, subValue) {
        if (subKey == '_name') {
          rule[subKey] = subValue;
        } else {
          rule[subKey] = subValue is List
              ? subValue.map((item) {
            if (item is String) {
              return item;
            } else {
              return Rule.fromJson(item as Map<String, dynamic>);
            }
          }).toList()
              : subValue;
        }
      });
      rules[key] = rule;
    });
    return Rules(rules);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    _rules.forEach((key, value) {
      final Map<String, dynamic> rule = {};
      value.forEach((subKey, subValue) {
        if (subKey == '_name') {
          rule[subKey] = subValue;
        } else {
          rule[subKey] = subValue is List
              ? subValue.map((item) {
            if (item is Rule) {
              return item.toJson();
            } else {
              return item;
            }
          }).toList()
              : subValue;
        }
      });
      json[key] = rule;
    });
    return json;
  }

  Map<String, dynamic> operator [](String domain) => _rules[domain] ?? {};

  void operator []=(String domain, Map<String, dynamic> value) {
    _rules[domain] = value;
  }
}