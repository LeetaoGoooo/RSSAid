import 'package:rssaid/models/rule.dart';

class SourceParser {
  final Position targetPosition;
  final String url;

  SourceParser(
      {required String target, required String url}):
        targetPosition = getPosition(target),
        url = url;

  static Position getPosition(String url) {
    List<String> partUrls = url.split("/").sublist(1);
    Map<String, PositionItem> replacePositions = {};
    for (var i = 0; i < partUrls.length; i++) {
      int isValidPartVal = isValidPart(partUrls[i]);
      if (isValidPartVal < 0) {
        continue;
      }
      String key = partUrls[i];
      bool optional = false;
      if (isValidPartVal == 2) {
        optional = true;
        key = partUrls[i].substring(0, partUrls[i].length - 1);
      }
      replacePositions[key] = PositionItem(position: i, optional: optional);
    }
    return Position(
        origin: url, replacePositions: replacePositions, strings: partUrls);
  }

  // 1 validate 2 validate and optional
  // -1 invalidate
  static int isValidPart(String part) {
    if (!part.startsWith(":")){
      return -1;
    }
    if (part.startsWith(":")) {
      if (part.endsWith("?")) {
        return 2;
      }
    }
    return 1;
  }

  String removeDomain(String url) {
    try {
      Uri uri = Uri.parse(url);
      return uri.path + (uri.query.isEmpty ? '' : '?${uri.query}');
    } catch (e) {
      return url; // Return original string if parsing fails
    }
  }


  bool isMatch(Position sourcePosition, String url) {
    var urlStrings = url.split("/").sublist(1);

    var sourceStrings = sourcePosition.strings;
    var sourceStringLen = sourceStrings.length;

    if (sourceStringLen != urlStrings.length) {
      return false;
    }

    for (var i= 0; i< sourceStringLen; i++) {
      var key = sourceStrings[i];
      if (!sourcePosition.replacePositions.keys.contains(key)) {
        var notReplaceStr = sourceStrings[i];
        if (notReplaceStr != urlStrings[i]) {
          return false;
        }
      }
    }
    return true;
  }

  String? getRule(List<String> sources) {
    var sourcePositions = sources.map((source) => getPosition(source)).toSet();

    var urlWithoutDomain = removeDomain(url);
    var urlStrings = urlWithoutDomain.split("/").sublist(1);

    Map<String, PositionItem>? item;
    for (var sourcePosition in sourcePositions) {
      var isMatched = isMatch(sourcePosition, urlWithoutDomain);
      if (isMatched) {
        item = sourcePosition.replacePositions;
        break;
      }
    }

    if (item == null) {
      return null;
    }

    var replacePositions = targetPosition.replacePositions;

    if (replacePositions.isEmpty) {
      return targetPosition.origin;
    }

    var originStrings = targetPosition.strings;


    for (var key in replacePositions.keys) {
      if ((!(replacePositions[key]!.optional) && !item.containsKey(key)) || !item.containsKey(key)) {
        return null;
      }
      int itemPosition = item[key]!.position;
      int replacePosition = replacePositions[key]!.position;
      originStrings[replacePosition] = urlStrings[itemPosition];
    }

    return originStrings.join("/");
  }
}
