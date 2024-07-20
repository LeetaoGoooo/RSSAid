import 'package:rssaid/models/rule.dart';

class SourceParser {
  final Position? targetPosition;
  final String url;

  SourceParser(
      {required String target, required String url}):
        targetPosition = getPosition(target),
        url = url;

  static Position? getPosition(String url) {
    List<String> partUrls = url.split("/").sublist(1);
    List<int> positions = [];
    for (var i = 0; i < partUrls.length; i++) {
      if (isValidPart(partUrls[i])) {
        positions.add(i);
      }
    }
    if (positions.length == 0) {
      return null;
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

  String? getRule(String source) {
    var sourcePosition = getPosition(source);
    if (sourcePosition == null) {
      return null;
    }

    if (targetPosition == null) {
      return null;
    }

    // https://www.leetao.me/posts/xxx
    // => /posts/xxx
    var urlWithoutDomain = removeDomain(url);
    var urlStrings = urlWithoutDomain.split("/").sublist(1);

    if (sourcePosition.replacePositions.length > urlStrings.length) {
      return null;
    }

    var replacePositions = sourcePosition.replacePositions;
    var originStrings = sourcePosition.strings;
    print('originStrings:${targetPosition!.origin} source:${sourcePosition.origin}');
    for (var i = 0; i <  replacePositions.length; i++) {
      var replacePosition = replacePositions[i];
      originStrings[replacePosition] = urlStrings[i];
    }
    var prefix = targetPosition!.strings
        .sublist(0, targetPosition!.replacePositions[0])
        .join("/");
    return '${prefix}/${originStrings.join("/")}';
  }
}
