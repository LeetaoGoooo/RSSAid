// @dart=2.9

import 'dart:convert';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: import_of_legacy_library_into_null_safe
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

class Common {

  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<void> launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    }
  }

  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

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

  static refreshRules() async{
    final SharedPreferences prefs = await _prefs;
    var url =
        'https://raw.githubusercontent.com/Cay-Zhang/RSSBudRules/main/radar-rules.js';
    var jsCode = await getContentByUrl(Uri.parse(url));
    await prefs.setString("Rules", "$jsCode");
  }
}
