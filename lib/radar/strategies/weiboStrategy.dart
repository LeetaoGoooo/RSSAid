
import 'package:rssaid/models/radar.dart';
import 'package:rssaid/radar/strategies/ruleStrategy.dart';

class Weibo implements RuleStrategy {
  @override
  List<Radar> detect(String url) {
    List<Radar> weiboRadars = [
      Radar.fromJson({"title": "微博热搜榜", "path": "/weibo/search/hot", "isRssHub": true})
    ];
    var uid = parseApp(url);
    uid = uid == null ? parsePC(url) : uid;
    uid = uid == null ?  parseH5(url) : uid;
    weiboRadars.addAll([
      Radar.fromJson({"title":"博主", "path": "/weibo/user/$uid", "isRssHub": true}),
      Radar.fromJson({"title":"博主 ❗", "path": "https://rssfeed.today/weibo/rss/$uid", "isRssHub": false})
    ]);
    return weiboRadars;
  }

  String? parseUrl(String url, RegExp pattern) {
    var match = pattern.firstMatch(url);
    if (match != null) {
      // return Radar.fromJson(
      //     {"title": "博主", "path": "/weibo/user/${match.group(1)}", "isRssHub": true});
      return match.group(1);
    }
    return null;
  }

  String? parsePC(String url) {
    return parseUrl(url, RegExp(r'https://.*weibo.*?/u/(\d+)'));
  }

  String? parseH5(String url) {
    return parseUrl(url, RegExp(r'https://m.weibo.*?/profile/(\d+)'));
  }

  String? parseApp(String url) {
    return parseUrl(url, RegExp(r'https://.*weibo.*?/u/(\d+)'));
  }
}
