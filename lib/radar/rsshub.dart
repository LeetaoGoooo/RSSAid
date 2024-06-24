import 'dart:convert';

import 'package:rssaid/models/radar.dart';
import 'package:rssaid/radar/rule_type/page_info.dart';
import 'package:rssaid/radar/rule_type/rule.dart';
import 'package:rssaid/shared_prefs.dart';
import 'package:tldts/core/index.dart';
import 'package:tldts/tldts.dart';

class Rsshub {
  final SharedPrefs prefs = SharedPrefs();


  List<Radar>? getPageRSSHub(PageInfo pageInfo) {
    String stringRules = prefs.rules;
    if (stringRules.isEmpty) {
      return [];
    }
    Map<String,dynamic> rssHubRules = jsonDecode(stringRules);

    Result? parsedDomain;

    try {
      parsedDomain = parse(pageInfo.url);
    } on FormatException catch (e) {
      print('Not valid URI:${e}');
      return [];
    } on Exception catch (e) {
      print('Unknown exception:${e}');
      return [];
    }
    String? domain = parsedDomain.domain;
    String? subdomain = parsedDomain.subdomain;
    if (domain != null) {
      if (rssHubRules[domain]) {
         List<Rule> rules = rssHubRules[domain][subdomain ?? "."];
         if (rules.isEmpty) {
           if (subdomain == "www") {
             rules = rssHubRules[domain]["."];
           } else if (subdomain!.isEmpty) {
             rules = rssHubRules[domain]['www'];
           }
         }
         if (rules.isNotEmpty) {
           var recognized = [];
           List<String> sources = [];
           for (var rule in rules) {
             List<String> oriSources =  rule.source;
             for (var oriSource in oriSources) {
               var source = oriSource.replaceAllMapped(
                   RegExp(r'(/:\w+)\?(?=/|$)'),
                       (match) => match.group(1)!
               );
               sources.add(source);

               while(true) {
                 Match? tailMatch = RegExp(r'/:\w+$').firstMatch(source);
                 if (tailMatch == null) break;
                 String tail = tailMatch.group(0)!;
                 source = source.substring(0, source.length - tail.length);
                 sources.add(source);
               }
             }
           }

           List<String> sources =  sources.toSet().toList();
            // TODO


         }
      }
    }

    return [];

  }
}