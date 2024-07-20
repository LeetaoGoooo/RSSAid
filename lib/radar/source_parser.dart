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
    List<int> positions = [];
    for (var i = 0; i < partUrls.length; i++) {
      if (isValidPart(partUrls[i])) {
        positions.add(i);
      }
    }
    return Position(
        origin: url, replacePositions: positions, strings: partUrls);
  }

  static bool isValidPart(String part) {
    return part.startsWith(":");
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
      if (!sourcePosition.replacePositions.contains(i)) {
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

    var isMatched = false;
    for (var sourcePosition in sourcePositions) {
      isMatched = isMatch(sourcePosition, urlWithoutDomain);
      if (isMatched) {
        break;
      }
    }

    if (!isMatched) {
      return null;
    }

    var replacePositions = targetPosition.replacePositions;

    if (replacePositions.isEmpty) {
      return targetPosition.origin;
    }

    var originStrings = targetPosition.strings;

    for (var i = 0; i <  replacePositions.length; i++) {
      var replacePosition = replacePositions[i];
      originStrings[replacePosition] = urlStrings[i];
    }

    return originStrings.join("/");
  }
}
