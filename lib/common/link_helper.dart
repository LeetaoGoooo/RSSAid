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


 static getSubscriptionUrl(Radar radar) async {
   Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
   final SharedPreferences prefs = await _prefs;
   var host = "https://rsshub.app/";
   if (prefs.containsKey("RSSHUB")) {
     host = prefs.getString("RSSHUB")!;
   }
   var url = "$host${radar.path}";
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