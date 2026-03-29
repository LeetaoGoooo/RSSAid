import 'package:flutter/foundation.dart';

import 'package:rssaid/models/radar.dart';
import 'package:rssaid/radar/rule_type/page_info.dart';
import 'package:rssaid/radar/rule_type/rule.dart';
import 'package:rssaid/radar/source_parser.dart';
import 'package:tldts/core/index.dart';
import 'package:tldts/tldts.dart';

class RssHub {

  Future<List<Radar>> getPageRSSHub(PageInfo pageInfo) async {
    List<Radar> radars = [];

    final Map<String, dynamic> rssHubRules = pageInfo.rules;
    if (rssHubRules.isEmpty) {
      return radars;
    }

    Result? parsedDomain;
    try {
      parsedDomain = parse(pageInfo.url);
    } on FormatException catch (e) {
      if (kDebugMode) print('Not valid URI: $e');
      return radars;
    } on Exception catch (e) {
      if (kDebugMode) print('Unknown exception: $e');
      return radars;
    }

    final String? domain = parsedDomain.domain;
    final String? subdomain = (parsedDomain.subdomain != null &&
            parsedDomain.subdomain!.isNotEmpty)
        ? parsedDomain.subdomain
        : null;

    if (domain == null || !rssHubRules.containsKey(domain)) {
      return radars;
    }

    List<dynamic>? rules = rssHubRules[domain][subdomain ?? '.'];

    if (rules == null || rules.isEmpty) {
      if (subdomain == 'www' || subdomain == 'mobile' || subdomain == 'm') {
        rules = rssHubRules[domain]['.'];
      } else if (subdomain == null || subdomain.isEmpty) {
        rules = rssHubRules[domain]['www'];
      }
    }

    if (rules == null || rules.isEmpty) {
      return radars;
    }

    for (var ruleMap in rules) {
      final rule = Rule.fromJson(ruleMap);
      final sourceParser = SourceParser(target: rule.target, url: pageInfo.url);
      final String? parsedRule = sourceParser.getRule(rule.source);
      if (parsedRule != null) {
        radars.add(Radar(
          title: rule.title,
          docs: rule.docs,
          isRssHub: true,
          path: parsedRule,
        ));
      }
    }
    return radars;
  }

  static List<String> parseSource(String url) {
    return url.split("/");
  }
}
