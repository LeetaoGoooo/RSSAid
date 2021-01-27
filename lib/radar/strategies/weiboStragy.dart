import 'package:rssaid/models/radar.dart';
import 'package:rssaid/radar/strategies/ruleStragy.dart';

class Weibo implements RuleStrategy {
  @override
  List<Radar> detect(String url) {
    List<Radar> weiboRadars = [
      Radar.fromJson({"title": "微博热搜榜", "path": "weibo/search/hot"})
    ];
    var radar = parseApp(url);
    if (radar != null) {
      weiboRadars.add(radar);
      return weiboRadars;
    }
    radar = parsePC(url);
    if (radar != null) {
      weiboRadars.add(radar);
      return weiboRadars;
    }
    radar = parseH5(url);
    if (radar != null) {
      weiboRadars.add(radar);
      return weiboRadars;
    }
    return null;
  }

  Radar parseUrl(String url, RegExp pattern) {
    var match = pattern.firstMatch(url);
    if (match != null) {
      return Radar.fromJson(
          {"title": "博主", "path": "weibo/user/${match.group(1)}"});
    }
    return null;
  }

  Radar parsePC(String url) {
    return parseUrl(url, RegExp(r'https://weibo.*?/u/(\d+)'));
  }

  Radar parseH5(String url) {
    return parseUrl(url, RegExp(r'https://m.weibo.*?/profile/(\d+)'));
  }

  Radar parseApp(String url) {
    return parseUrl(url, RegExp(r'https://weibo.*?/u/(\d+)'));
  }
}
