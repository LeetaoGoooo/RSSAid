import 'dart:convert';

import 'package:rssaid/models/radar.dart';
import 'package:rssaid/radar/rule_type/page_info.dart';
import 'package:rssaid/radar/rule_type/rule.dart';
import 'package:rssaid/radar/source_parser.dart';
import 'package:rssaid/shared_prefs.dart';
import 'package:tldts/core/index.dart';
import 'package:tldts/tldts.dart';

class RssHub {
  final SharedPrefs prefs = SharedPrefs();

  List<Radar> getPageRSSHub(PageInfo pageInfo) {
    List<Radar> radars = [];

    String stringRules = prefs.rules;
    if (stringRules.isEmpty) {
      return radars;
    }
    Map<String, dynamic> rssHubRules = jsonDecode(stringRules);

    Result? parsedDomain;

    try {
      parsedDomain = parse(pageInfo.url);
    } on FormatException catch (e) {
      print('Not valid URI:${e}');
      return radars;
    } on Exception catch (e) {
      print('Unknown exception:${e}');
      return radars;
    }

    String? domain = parsedDomain.domain;
    String? subdomain = parsedDomain.subdomain != null && parsedDomain.subdomain!.isNotEmpty ?  parsedDomain.subdomain : null;

    if (domain == null) {
      return radars;
    }

    if (!rssHubRules.containsKey(domain)) {
      return radars;
    }

    List<dynamic> rules = rssHubRules[domain][subdomain ?? "."];

    if (rules.isEmpty) {
      if (subdomain == "www") {
        rules = rssHubRules[domain]["."];
      } else if (subdomain!.isEmpty) {
        rules = rssHubRules[domain]['www'];
      }
    }

    if (rules.isEmpty) {
      return radars;
    }

    for (var ruleMap in rules) {
      var rule = Rule.fromJson(ruleMap);
      Radar radar = Radar(title: rule.title, docs: rule.docs, isRssHub: true);
      var sourceParser = SourceParser(target: rule.target, url: pageInfo.url);

      String? parsedRule = sourceParser.getRule(rule.source);
      if (parsedRule != null) {
        radar.path = parsedRule;
        radars.add(radar);
      }
    }
    return radars;
  }

  static List<String> parseSource(String url) {
    return url.split("/");
  }
}
