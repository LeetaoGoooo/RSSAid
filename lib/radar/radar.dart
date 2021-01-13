import 'dart:convert';
import 'dart:io';

import 'package:rssaid/models/radar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension UriExtension on Uri {
  Future<Uri> expanding() async {
    var httpClient = new HttpClient();
    var request = await httpClient.headUrl(this);
    request.followRedirects = false;
    var response = await request.close();
    var location = response.headers.value("Location");
    return location != null ? Uri.parse(location) : this;
  }
}

class RssHubJsContext {
  JavascriptRuntime flutterJs;

  RssHubJsContext() {
    flutterJs = getJavascriptRuntime();
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
      var httpClient = new HttpClient();
      var request = await httpClient.getUrl(uri);
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
        'https://cdn.jsdelivr.net/gh/DIYgod/RSSHub@master/assets/radar-rules.js';
    var jsCode = await getContentByUrl(Uri.parse(url));
    if (jsCode.isNotEmpty) {
      prefs.setString("Rules", "var rules=$jsCode ");
      jsContext.flutterJs.evaluate("var rules=$jsCode ");
    } else {
      print('load local rules');
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
    await fetchRules();
    await jsContext.evaluateScript('assets/js/url.min.js');
    await jsContext.evaluateScript('assets/js/psl.min.js');
    await jsContext.evaluateScript('assets/js/route-recognizer.min.js');
    await jsContext.evaluateScript('assets/js/route-recognizer.js');
  
    await jsContext.evaluateScript('assets/js/dom-parser.min.js');


    await jsContext.evaluateScript('assets/js/utils.js');
    await jsContext.evaluateScript('assets/js/url.js');
    Uri uri = await Uri.parse(url).expanding();
    try {
      String expression = """
      getPageRSSHub({
                            url: "$url",
                            host: "${uri.host}",
                            path: "${uri.path}",
                            html: "",
                            rules: rules
                        })
      """;

      jsContext.flutterJs.enableHandlePromises();
      var jsResult = jsContext.flutterJs.evaluate(expression);
      var result = jsResult.stringResult;
      return Radar.listFromJson(json.decode(result));
    } on PlatformException catch (e) {
      print('ERRO: ${e.details}');
    }
    return null;
  }
}
