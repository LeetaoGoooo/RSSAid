import 'dart:collection';
import 'dart:convert';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'dart:io';

import 'package:rssaid/models/radar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:rssaid/radar/rules.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_proxy/system_proxy.dart';

extension HttpClientExtension on HttpClient {
  Future<HttpClient> autoProxy() async {
    Map<String, String> sysProxy = await SystemProxy.getProxySettings();
    var proxy = "DIRECT";
    if (sysProxy != null) {
      proxy = "PROXY ${sysProxy['host']}:${sysProxy['port']}; DIRECT";
      print("find proxy $proxy");
    }
    this.findProxy = (uri) {
      return proxy;
    };
    return this;
  }
}

extension UriExtension on Uri {
  Future<Uri> expanding() async {
    try {
      var httpClient = await new HttpClient().autoProxy();
      httpClient.connectionTimeout = Duration(seconds: 5);
      var request = await httpClient.headUrl(this);
      request.followRedirects = false;
      var response = await request.close();
      var location = response.headers.value("Location");
      return location != null ? Uri.parse(location) : this;
    } catch (e) {
      return this;
    }
  }
}

class RssHubJsContext {
  JavascriptRuntime flutterJs;

  RssHubJsContext() {
    flutterJs = getJavascriptRuntime();
    flutterJs.onMessage("console", (args) {
      print(args);
    });
  }
  evaluateScript(String filePath) async {
    try {
      var js = await rootBundle.loadString(filePath);
      flutterJs.evaluate(js + " ");
    } catch (error) {
      throw Exception("load js file failed:$error");
    }
  }
}

class RssHub {
  static RssHubJsContext jsContext = new RssHubJsContext();
  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<String> getContentByUrl(Uri uri) async {
    var content = "";
    try {
      var httpClient = await new HttpClient().autoProxy();
      httpClient.connectionTimeout = Duration(seconds: 10);
      var request = await httpClient.getUrl(uri);
      request.headers.set("User-Agent", "RSSAid");
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        content = await response.transform(utf8.decoder).join();
      }
    } catch (error) {
      print('get content by url failed:$error');
    }
    return content;
  }

  static Future<void> fetchRules() async {
    final SharedPreferences prefs = await _prefs;
    var url =
        'https://cdn.jsdelivr.net/gh/lt94/RSSAid@main/assets/js/radar-rules.js';
    var jsCode = await getContentByUrl(Uri.parse(url));
    if (jsCode.isNotEmpty) {
      prefs.setString("Rules", "$jsCode");
      jsContext.flutterJs.evaluate("$jsCode ");
    } else {
      if (!prefs.containsKey("Rules")) {
        var js = await rootBundle.loadString("assets/js/radar-rules.js");
        prefs.setString("Rules", js);
        await jsContext.evaluateScript('assets/js/radar-rules.js');
      } else {
        jsContext.flutterJs.evaluate(prefs.getString("Rules"));
      }
    }
  }

  static Future<List<Radar>> detecting(String url) async {
    var specialRadar = Rules.detectUrl(url);
    if (specialRadar != null) {
      return specialRadar;
    }

    return [...await detectByRssHub(url), ...await detectByUrl(url)];
  }

  static Future<List<Radar>> detectByRssHub(String url) async {
    await fetchRules();
    await jsContext.evaluateScript('assets/js/url.min.js');
    await jsContext.evaluateScript('assets/js/psl.min.js');
    await jsContext.evaluateScript('assets/js/route-recognizer.min.js');
    await jsContext.evaluateScript('assets/js/route-recognizer.js');
    await jsContext.evaluateScript('assets/js/dom-parser.min.js');
    await jsContext.evaluateScript('assets/js/utils.js');
    await jsContext.evaluateScript('assets/js/url.js');

    List<Radar> radarList = List<Radar>();

    Uri uri = await Uri.parse(url).expanding();
    String html = await getContentByUrl(uri);
    try {
      String expression = """
      getPageRSSHub({
                            url: "$url",
                            host: "${uri.host}",
                            path: "${uri.path}",
                            html: `$html`,
                            rules: rules
                        })
      """;
      jsContext.flutterJs.enableHandlePromises();
      var jsResult = jsContext.flutterJs.evaluate(expression);
      var result = jsResult.stringResult;
      radarList = Radar.listFromJson(json.decode(result));
    } catch (e) {
      print('ERRO: $e');
    }
    return radarList;
  }

  static Future<List<Radar>> detectByUrl(String url) async {
    List<Radar> radarList = List<Radar>();
    String html = await getContentByUrl(Uri.parse(url));
    Document document = parse(html);
    try {
    radarList = await parseKnowedRss(document, url);
    radarList += await parseUnKnowedRss(document, url);
    radarList = radarList.toSet().toList();
    } catch (e) {
      print("parseRss error:$e");
    }
    return radarList;
  }

  /// 获取在<head>的<link>元素中，已经声明为RSS的链接
  static Future<List<Radar>> parseKnowedRss(
      Document document, String url) async {
    List<Radar> radarList = List<Radar>();
    List<Element> links = document.getElementsByTagName("link");
    for (var i = 0; i < links.length; i++) {
      var link = links[i];
      if (link != null) {
        LinkedHashMap attrs = link.attributes;
        String linkHref = attrs['href'];
        String linkType = attrs['type'];
        String linkTitle = attrs.containsKey("title")
            ? attrs['title']
            : document.getElementsByTagName("title")[0].text;
        RegExp rssPattern = new RegExp(r'.+\/(rss|rdf|atom)');
        RegExp xmlPattern = new RegExp(r'^text\/xml$');
        if (linkType != null &&
            linkType.isNotEmpty &&
            (rssPattern.hasMatch(linkType) || xmlPattern.hasMatch(linkType))) {
          print("符合条件的链接:$linkHref,主题:$linkTitle");
          Uri uri = Uri.parse(url);
          if (!linkHref.startsWith("http") && !linkHref.contains(uri.host)) {
            linkHref = '${uri.scheme}://${uri.host}$linkHref';
          }
          Radar radar = new Radar.fromJson(
              {"title": linkTitle, "path": linkHref, "isRssHub": false});
          print("radar isRssHub:${radar.isRssHub}");
          radarList.add(radar);
        }
      }
    }
    print("解析结果:$radarList");
    return radarList;
  }

  static Future<List<Radar>> parseUnKnowedRss(
      Document document, String url) async {
    List<Element> links = document.getElementsByTagName("a");
    List<Radar> radarList = List<Radar>();
    Uri uri = Uri.parse(url);

    for (var i = 0; i < links.length; i++) {
      var link = links[i];
      if (link != null) {
        LinkedHashMap attrs = link.attributes;
        String linkHref = attrs['href'];
        String linkTitle =
            attrs.containsKey("title") ? attrs['title'] : link.text;
        if (linkTitle.isEmpty) {
          linkTitle = document.getElementsByTagName("title")[0].text;
        }
        if (linkHref != null  &&
            (new RegExp(r'^(https|http|ftp|feed).*([\.\/]rss([\.\/]xml|\.aspx|\.jsp|\/)?$|\/node\/feed$|\/feed(\.xml|\/$|$)|\/rss\/[a-z0-9]+$|[?&;](rss|xml)=|[?&;]feed=rss[0-9.]*$|[?&;]action=rss_rc$|feeds\.feedburner\.com\/[\w\W]+$)')
                    .hasMatch(linkHref) ||
                new RegExp(
                        r'^(https|http|ftp|feed).*\/atom(\.xml|\.aspx|\.jsp|\/)?$|[?&;]feed=atom[0-9.]*$')
                    .hasMatch(linkHref) ||
                new RegExp(
                        r'^(https|http|ftp|feed).*(\/feeds?\/[^.\/]*\.xml$|.*\/index\.xml$|feed\/msgs\.xml(\?num=\d+)?$)')
                    .hasMatch(linkHref) ||
                new RegExp(r'^(https|http|ftp|feed).*\.rdf$')
                    .hasMatch(linkHref) ||
                new RegExp(r'^(rss|feed):\/\/').hasMatch(linkHref) ||
                new RegExp(r'^(https|http):\/\/feed\.').hasMatch(linkHref))) {
          if (!linkHref.startsWith("http") && !linkHref.contains(uri.host)) {
            linkHref = '${uri.scheme}://${uri.host}$linkHref';
          }
          Radar radar = new Radar.fromJson(
              {"title": linkTitle, "path": linkHref, "isRssHub": false});
          print("radar isRssHub:${radar.isRssHub}");
          radarList.add(radar);
        }
      }
    }
    return radarList;
  }
}
