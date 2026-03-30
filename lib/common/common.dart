import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_proxy/system_proxy.dart';

extension HttpClientExtension on HttpClient {
  Future<HttpClient> autoProxy() async {
    Map<String, String>? sysProxy = await SystemProxy.getProxySettings();
    var proxy = "DIRECT";
    if (sysProxy != null) {
      print('DETECTED_PROXY: ${sysProxy}');
      proxy = "PROXY ${sysProxy['host']}:${sysProxy['port']}; DIRECT";
    } else {
      print('DETECTED_PROXY: NONE');
    }
    this.findProxy = (uri) {
      return proxy;
    };
    this.badCertificateCallback = (cert, host, port) => true;
    return this;
  }
}

class Common {
  static const String jsDelivrRulesUrl =
      "https://fastly.jsdelivr.net/gh/DIYgod/RSSHub@gh-pages/radar-rules.js";
  static const String rsshubRadarRulesJsonUrl =
      "https://raw.githubusercontent.com/DIYgod/RSSHub/gh-pages/radar-rules.js";
  static const String radarMirrorUrl =
      "https://rsshub.app/radar-rules.js";

  // In-memory cache: avoids re-deserializing the large JSON on every URL detection.
  static Map<String, dynamic>? _cachedParsedRules;
  static String? _cachedRulesSource;
  static Future<String?>? _pendingRulesFetch;

  static Future<String?> getContentByUrl(dynamic url, {bool useProxy = true}) async {
    try {
      Uri uri;
      if (url is String) {
        uri = Uri.parse(url);
      } else if (url is Uri) {
        uri = url;
      } else {
        return null;
      }
      
      HttpClient httpClient;
      if (useProxy) {
        httpClient = await HttpClient().autoProxy();
      } else {
        print('FETCHING_DIRECT: $url');
        httpClient = HttpClient();
        httpClient.badCertificateCallback = (cert, host, port) => true;
      }

      httpClient.connectionTimeout = const Duration(seconds: 60);
      var request = await httpClient.getUrl(uri);
      
      // Mimic a modern mobile browser and official extension to bypass 403s
      request.headers.set("User-Agent", "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1");
      request.headers.set("Accept", "application/json, text/plain, */*");
      request.headers.set("Accept-Language", "zh-CN,zh;q=0.9,en;q=0.8");
      request.headers.set("Cache-Control", "no-cache");
      request.headers.set("Pragma", "no-cache");
      request.headers.set("Referer", "https://rsshub.app/");
      request.headers.set("X-Requested-With", "XMLHttpRequest");
      request.headers.set("Origin", "chrome-extension://kbmfpngjjgdllneeigpgnljpghcabnoo");
      request.headers.set("Sec-CH-UA", '"Google Chrome";v="123", "Not:A-Brand";v="8", "Chromium";v="123"');
      request.headers.set("Sec-CH-UA-Mobile", "?1");
      request.headers.set("Sec-CH-UA-Platform", '"iOS"');
      request.headers.set("Sec-Fetch-Dest", "empty");
      request.headers.set("Sec-Fetch-Mode", "cors");
      request.headers.set("Sec-Fetch-Site", "same-site");

      var response = await request.close();
      
      print('HTTP_RESPONSE: ${response.statusCode} (Proxy: $useProxy) for $url');
      if (response.statusCode == 200) {
        return await response.transform(utf8.decoder).join();
      }
    } catch (e) {
      print('GET_CONTENT_ERROR (Proxy: $useProxy): $e');
    }
    return null;
  }

  static Future<void> launchInBrowser(String url) async {
    if (await launcher.canLaunch(url)) {
      await launcher.launch(url);
    }
  }

  static bool isNumeric(String? s) {
    if (s == null) return false;
    return double.tryParse(s) != null;
  }

  static Future<String?> refreshRules() async {
    // Clear in-memory cache so the new rules are picked up immediately.
    _cachedParsedRules = null;
    _cachedRulesSource = null;
    return await getRules(forceRefresh: true);
  }

  /// Returns the parsed rules Map, using an in-memory cache to avoid
  /// re-deserializing the large JSON on every URL detection call.
  static Future<Map<String, dynamic>?> getParsedRules(
      {bool forceRefresh = false}) async {
    if (forceRefresh) {
      _cachedParsedRules = null;
      _cachedRulesSource = null;
    }

    String? rawRules = await getRules(forceRefresh: forceRefresh);
    if (rawRules == null || rawRules.isEmpty) return null;

    // Return cached result if the raw string hasn't changed.
    if (_cachedParsedRules != null && _cachedRulesSource == rawRules) {
      return _cachedParsedRules;
    }

    // Parse in a background isolate to keep the UI thread free.
    try {
      _cachedParsedRules = await compute(_parseRules, rawRules);
      _cachedRulesSource = rawRules;
    } catch (e) {
      if (kDebugMode) print('PARSE_RULES_ERROR: $e');
      // If parsing fails (e.g., stale JS in cache), clear stale rules and try assets
      if (!forceRefresh) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('radar-rules');
        return getParsedRules(forceRefresh: true);
      }
    }
    return _cachedParsedRules;
  }

  static Map<String, dynamic> _parseRules(String rules) {
    return jsonDecode(rules) as Map<String, dynamic>;
  }

  static Future<String?> getRules({bool forceRefresh = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!forceRefresh) {
      String? cachedRules = prefs.getString('radar-rules');
      // ONLY return from cache if it looks like a valid JSON object
      if (cachedRules != null && cachedRules.isNotEmpty && cachedRules.trim().startsWith('{')) {
        return cachedRules;
      }
    }

    // Reuse ongoing fetch if one exists to avoid redundant concurrent requests
    if (_pendingRulesFetch != null) {
      return _pendingRulesFetch;
    }

    _pendingRulesFetch = _fetchAndLevelRules().then((rules) async {
      if (rules != null && rules.isNotEmpty) {
        await prefs.setString('radar-rules', rules);
        return rules;
      }
      
      // If network fails, try stored rules from disk
      String? stored = prefs.getString('radar-rules');
      if (stored != null && stored.isNotEmpty) {
        return stored;
      }

      // Final fallback: Load from bundled assets (Decisive Hardening)
      try {
        print('FETCH_RULES_FALLBACK: Loading bundled assets/radar-rules.json');
        return await rootBundle.loadString('assets/radar-rules.json');
      } catch (e) {
        print('FETCH_RULES_ERROR (Assets): $e');
        return null;
      }
    }).catchError((e) {
      _pendingRulesFetch = null;
      throw e;
    }).whenComplete(() {
      _pendingRulesFetch = null;
    });

    return _pendingRulesFetch;
  }

  static Future<String?> _fetchAndLevelRules() async {
    final sources = [
      {'name': 'Official Build (jsDelivr)', 'url': jsDelivrRulesUrl},
      {'name': 'Official Build (GitHub gh-pages)', 'url': rsshubRadarRulesJsonUrl},
      {'name': 'Official Mirror (Backup)', 'url': radarMirrorUrl},
    ];

    for (var source in sources) {
      String name = source['name']!;
      String url = source['url']!;

      // 1. Try with Proxy first
      try {
        String? body = await getContentByUrl(url, useProxy: true);
        if (body != null && body.isNotEmpty) {
          print('FETCH_RULES_SUCCESS: $name (Proxy)');
          return sanitizeTsToJson(body);
        }
      } catch (e) {
        print('FETCH_RULES_ERROR: $name (Proxy): $e');
      }

      // 2. Try Direct fallback if Proxy failed or returned empty/error
      try {
        String? body = await getContentByUrl(url, useProxy: false);
        if (body != null && body.isNotEmpty) {
          print('FETCH_RULES_SUCCESS: $name (Direct)');
          return sanitizeTsToJson(body);
        }
      } catch (e) {
        print('FETCH_RULES_ERROR: $name (Direct): $e');
      }
    }
    
    return null;
  }

  static String sanitizeTsToJson(String ts) {
    try {
      final trimmed = ts.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        print('PARSE_STATUS: Native JSON detected, skipping sanitization.');
        return ts;
      }

      // Find where rules = [...] or export default [...] starts.
      int start = ts.indexOf('[');
      if (ts.contains('rules =')) {
        start = ts.indexOf('[', ts.indexOf('rules ='));
      } else if (ts.contains('export default')) {
        start = ts.indexOf('[', ts.indexOf('export default'));
      }
      
      int end = ts.lastIndexOf(']');
      if (start == -1 || end == -1) return ts;
      String content = ts.substring(start, end + 1);

      // Protect URLs
      content = content.replaceAll('://', '___URL_SEP___');

      // 1. Remove comments
      content = content.replaceAll(RegExp(r'(^|\s)//.*'), r'\$1');
      content = content.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');

      // 2. Handle template literals and backticks EARLY
      while (content.contains('`')) {
        content = content.replaceFirst('`', '"');
      }
      content = content.replaceAll(RegExp(r'\\?\$\{[^}]*\}'), '');

      // 3. Remove functional values (target/path) using structural scanning
      content = _stripFunctionalValues(content);

      // 4. Restore protected URL separator
      content = content.replaceAll('___URL_SEP___', '://');

      // 5. Quote unquoted keys while avoiding corrupting URLs
      content = content.replaceAllMapped(RegExp(r'([{,]\s*)([a-zA-Z0-9_\$]+)(?=\s*:(?!//))'), (match) {
        return '\${match.group(1)}"\${match.group(2)}"';
      });

      // 6. Transform single quotes to double quotes
      content = content.replaceAll("'", '"');

      // 7. Fix common JSON issues (trailing commas)
      content = content.replaceAllMapped(RegExp(r',(\s*[}\]])'), (match) {
        return match.group(1)!;
      });
      
      return content;
    } catch (e) {
      print('SANITIZE_TS_ERROR: \$e');
      return ts;
    }
  }

  static String _stripFunctionalValues(String content) {
    final propRegex = RegExp(r'("?target"?|"?path"?)\s*:\s*');
    final matches = propRegex.allMatches(content).toList().reversed;
    
    String result = content;
    for (var match in matches) {
      int valueStart = match.end;
      String remaining = result.substring(valueStart);
      
      String trimmed = remaining.trim();
      bool isFunction = trimmed.startsWith('(') || 
                       trimmed.startsWith('function') || 
                       trimmed.startsWith('=>') ||
                       (trimmed.contains('=>') && !trimmed.contains('"') && !trimmed.contains("'"));
                       
      if (isFunction) {
        int endPos = -1;
        int braceDepth = 0;
        for (int i = 0; i < remaining.length; i++) {
          if (remaining[i] == '{') braceDepth++;
          if (remaining[i] == '}') {
            braceDepth--;
            if (braceDepth < 0) {
              endPos = i;
              break;
            }
            if (braceDepth == 0) {
              endPos = i + 1;
              break;
            }
          }
          if (remaining[i] == ',' && braceDepth == 0) {
            endPos = i;
            break;
          }
        }
        
        if (endPos != -1) {
          result = result.replaceRange(valueStart, valueStart + endPos, ' ""');
        }
      }
    }
    return result;
  }
}
