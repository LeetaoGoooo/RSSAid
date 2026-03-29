import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:shared_preferences/shared_preferences.dart';

class Common {
  static const String rsshubRadarRulesUrl =
      "https://raw.githubusercontent.com/DIYgod/RSSHub/master/assets/radar-rules.json";
  static const String radarMirrorUrl =
      "https://radar.rsshub.app/rules.json";

  // In-memory cache: avoids re-deserializing the large JSON on every URL detection.
  static Map<String, dynamic>? _cachedParsedRules;
  static String? _cachedRulesSource;

  static Future<String?> getContentByUrl(dynamic url) async {
    try {
      Uri uri;
      if (url is String) {
        uri = Uri.parse(url);
      } else if (url is Uri) {
        uri = url;
      } else {
        return null;
      }
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      print('GET_CONTENT_ERROR: \$e');
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

  static Future<void> refreshRules() async {
    // Clear in-memory cache so the new rules are picked up immediately.
    _cachedParsedRules = null;
    _cachedRulesSource = null;
    await getRules(forceRefresh: true);
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
      if (kDebugMode) print('PARSE_RULES_ERROR: \$e');
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
      if (cachedRules != null && cachedRules.isNotEmpty) {
        return cachedRules;
      }
    }

    // Attempt to refresh
    String? rules = await _fetchAndLevelRules();
    if (rules != null && rules.isNotEmpty) {
      await prefs.setString('radar-rules', rules);
      return rules;
    }
    
    return prefs.getString('radar-rules');
  }

  static Future<String?> _fetchAndLevelRules() async {
    // Primary: GitHub Raw Master
    try {
      String? body = await getContentByUrl(rsshubRadarRulesUrl);
      if (body != null) {
        return sanitizeTsToJson(body);
      }
    } catch (e) {
      print('FETCH_RULES_ERROR (GitHub): \$e');
    }

    // Fallback: Radar Mirror
    try {
      String? body = await getContentByUrl(radarMirrorUrl);
      if (body != null) {
        return sanitizeTsToJson(body);
      }
    } catch (e) {
      print('FETCH_RULES_ERROR (Mirror): \$e');
    }
    
    return null;
  }

  static String sanitizeTsToJson(String ts) {
    try {
      int start = ts.indexOf('{');
      int end = ts.lastIndexOf('}');
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
