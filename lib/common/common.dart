import 'dart:convert';
import 'dart:io';

import 'package:rssaid/common/link_helper.dart';
import 'package:rssaid/shared_prefs.dart';
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
  static SharedPrefs prefs = SharedPrefs();

  static Future<void> launchInBrowser(String url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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
    var url = '${prefs.domain}/api/radar/rules';
    if (prefs.accessControl) {
      url = '${url}?key=${prefs.accessKey}';
    }
    var ruleUrl = LinkHelper.removeDuplicateSlashes(url);
    var jsonResp = await getContentByUrl(Uri.parse(ruleUrl));
    if (jsonResp != null) {
      prefs.rules = jsonResp;
    }
  }

  static Future<String?> getRules()  async {
    await Common.refreshRules();
    return prefs.rules;
  }
}
