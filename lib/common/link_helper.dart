import 'package:linkify/linkify.dart';
import 'package:rssaid/models/radar.dart';
import 'package:rssaid/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinkHelper {
  final SharedPrefs prefs = SharedPrefs();
  /// verify link return link
  /// else return null
 static String? verifyLink(String? url) {
    var links = linkify(url!.trim(),
        options: LinkifyOptions(humanize: false),
        linkifiers: [UrlLinkifier()])
        .where((element) => element is LinkableElement);
    if (links.isEmpty) {
      return null;
    }
    return links.first.text;
  }

  static String removeDuplicateSlashes(String url) {
    // Split the URL into components
    Uri uri = Uri.parse(url);

    // Get the scheme (e.g., https://)
    String scheme = uri.scheme;

    // Get the authority (e.g., www.baidu.com)
    String authority = uri.authority;

    // Get the path (e.g., /path/to/resource)
    String path = uri.path.replaceAll(RegExp(r'/{2,}'), '/');

    // Get the query (e.g., ?hello)
    String query = uri.query;

    // Get the fragment (e.g., #anchor)
    String fragment = uri.fragment;

    // Construct the new URL with no duplicated slashes
    String newUrl = '$scheme://$authority$path';

    // Append the query if it exists
    if (query.isNotEmpty) {
      newUrl += '?$query';
    }

    // Append the fragment if it exists
    if (fragment.isNotEmpty) {
      newUrl += '#$fragment';
    }

    return newUrl;
  }

 static getSubscriptionUrl(Radar radar) async {
   Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
   final SharedPreferences prefs = await _prefs;
   var host = "https://rsshub.app/";
   if (prefs.containsKey("RSSHUB")) {
     host = prefs.getString("RSSHUB")!;
   }
   var url = "$host${radar.path}";
   url = removeDuplicateSlashes(url);
   if (!radar.isRssHub) {
     url = radar.path!;
   }

   if (prefs.containsKey("currentParams")) {
     url += prefs.getString("currentParams")!;
   } else {
     url += (prefs.containsKey("defaultParams")
         ? prefs.getString("defaultParams")
         : "")!;
   }
   return url;
 }


}