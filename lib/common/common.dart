import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:system_proxy/system_proxy.dart';

extension HttpClientExtension on HttpClient {
  Future<HttpClient> autoProxy() async {
    Map<String, String>? sysProxy = await SystemProxy.getProxySettings();
    var proxy = "DIRECT";
    if (sysProxy != null) {
      proxy = "PROXY ${sysProxy['host']}:${sysProxy['port']}; DIRECT";
    }
    this.findProxy = (uri) {
      return proxy;
    };
    return this;
  }
}

class Common {
  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<void> launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    }
  }

  static bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static Future<String?> getContentByUrl(Uri uri) async {
    String? content;
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

  static refreshRules() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.containsKey("Rules")) {
      return;
    }
    var url =
        'https://raw.githubusercontent.com/Cay-Zhang/RSSBudRules/main/rules/radar-rules.js';

    if (prefs.containsKey("ruleSource")) {
      url = prefs.getString("ruleSource")!;
    }

    var jsCode = await getContentByUrl(Uri.parse(url));
    if (jsCode != null) {
      bool setRules = await prefs.setString("Rules", "$jsCode");
      if (setRules) {
        print('成功加载规则文件!');
      }
    }
  }

  static Future<String> getRules() async {
    await Common.refreshRules();
    final SharedPreferences prefs = await _prefs;
    return prefs.getString("Rules")!;
  }

  static Future<bool> setRuleSource(String source) async {
    final SharedPreferences prefs = await _prefs;
    return await prefs.setString("ruleSource", source);
  }
}
