import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:rssbud/models/radar.dart';

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

  static Future<void> fetchRules() async {
    try {
      var url =
          'https://cdn.jsdelivr.net/gh/DIYgod/RSSHub@master/assets/radar-rules.js';
      var httpClient = new HttpClient();
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        var jsCode = await response.transform(utf8.decoder).join();
        jsContext.flutterJs.evaluate("var rules=$jsCode ");
      }
    } catch (error) {
      print('load local rules');
      await jsContext.evaluateScript('assets/js/radar-rules.js');
    }
  }

  static Future<List<Radar>> detecting(String url) async {
    await fetchRules();
    await jsContext.evaluateScript('assets/js/url.min.js');
    await jsContext.evaluateScript('assets/js/psl.min.js');
    await jsContext.evaluateScript('assets/js/route-recognizer.js');
    await jsContext.evaluateScript('assets/js/route-recognizer.min.js');
    await jsContext.evaluateScript('assets/js/utils.js');
    Uri uri = Uri.parse(url);
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
