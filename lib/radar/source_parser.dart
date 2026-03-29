import 'package:flutter/foundation.dart';
import 'package:rssaid/models/rule.dart';

class SourceParser {
  final Position targetPosition;
  final String url;

  SourceParser({required String target, required String url})
      : targetPosition = getPosition(target),
        url = url;

  static Position getPosition(String url) {
    // Standardize URL by removing leading /
    String standardizedUrl = url.startsWith('/') ? url.substring(1) : url;
    List<String> partUrls = standardizedUrl.split("/");
    Map<String, PositionItem> replacePositions = {};
    
    for (var i = 0; i < partUrls.length; i++) {
      int isValidPartVal = isValidPart(partUrls[i]);
      if (isValidPartVal < 0) continue;

      String key;
      bool optional = false;
      if (isValidPartVal == 2) { // :param?
        optional = true;
        key = partUrls[i].substring(1, partUrls[i].length - 1);
      } else { // :param
        key = partUrls[i].substring(1);
      }
      replacePositions[key] = PositionItem(position: i, optional: optional);
    }
    return Position(origin: url, replacePositions: replacePositions, strings: partUrls);
  }

  static int isValidPart(String part) {
    if (part.startsWith(":")) {
      return part.endsWith("?") ? 2 : 1;
    }
    if (part.startsWith("*")) return 3;
    return -1;
  }

  String removeDomain(String url) {
    try {
      Uri uri = Uri.parse(url);
      String path = uri.path;
      if (path.startsWith('/')) path = path.substring(1);
      if (path.endsWith('/')) path = path.substring(0, path.length - 1);
      return path;
    } catch (e) {
      return url;
    }
  }

  bool isMatch(Position sourcePosition, String path) {
    var pathSegments = path.split("/").where((s) => s.isNotEmpty).toList();
    var ruleSegments = sourcePosition.strings.where((s) => s.isNotEmpty).toList();

    int pathIdx = 0;
    int ruleIdx = 0;

    while (ruleIdx < ruleSegments.length) {
      String ruleSeg = ruleSegments[ruleIdx];

      if (ruleSeg.startsWith(':')) {
        bool isOptional = ruleSeg.endsWith('?');
        if (pathIdx < pathSegments.length) {
          pathIdx++;
          ruleIdx++;
        } else if (isOptional) {
          ruleIdx++;
        } else {
          return false;
        }
      } else if (ruleSeg.startsWith('*')) {
        return true; // Match everything else
      } else {
        if (pathIdx < pathSegments.length && pathSegments[pathIdx] == ruleSeg) {
          pathIdx++;
          ruleIdx++;
        } else {
          return false;
        }
      }
    }

    // A match is successful if we consumed all mandatory rule segments 
    // AND either matched all path segments or the rule ended with a wildcard.
    // However, RSSHub Radar usually expects exact path match unless wildcard.
    return pathIdx == pathSegments.length;
  }

  String? getRule(List<dynamic> sources) {
    var path = removeDomain(url);
    var pathSegments = path.split("/").where((s) => s.isNotEmpty).toList();

    for (var source in sources) {
      if (source is! String) continue;
      var sourcePosition = getPosition(source);
      
      if (isMatch(sourcePosition, path)) {
        var replacePositions = targetPosition.replacePositions;
        if (replacePositions.isEmpty) return targetPosition.origin;

        List<String> resultSegments = List.from(targetPosition.strings);
        Map<String, PositionItem> sourceReplaceMap = sourcePosition.replacePositions;

        for (var entry in replacePositions.entries) {
          String key = entry.key;
          PositionItem targetItem = entry.value;
          
          if (sourceReplaceMap.containsKey(key)) {
            int srcIdx = sourceReplaceMap[key]!.position;
            if (srcIdx < pathSegments.length) {
              resultSegments[targetItem.position] = pathSegments[srcIdx];
            }
          }
        }
        
        String result = "/" + resultSegments.join("/");
        result = result.replaceAll(RegExp(r'/+'), '/');
        if (result.endsWith('/')) result = result.substring(0, result.length - 1);
        if (kDebugMode) print('SOURCE_PARSER: generated rule: $result');
        return result;
      }
    }
    return null;
  }
}
