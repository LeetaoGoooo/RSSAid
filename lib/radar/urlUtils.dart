import 'dart:io';

import 'package:rssaid/common/common.dart';

class UrlUtils {
  static getPcWebSiteUrl(String url) async {
    try {
      var httpClient = await new HttpClient().autoProxy();
      httpClient.connectionTimeout = Duration(seconds: 10);
      var request = await httpClient.getUrl(Uri.parse(url));
      // TODO random pc user-agent
      request.headers.set("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36");
      request.followRedirects = false;
      var response = await request.close();
      if (response.isRedirect) {
        final location = response.headers.value(HttpHeaders.locationHeader);
        return location;
      }
       return url;
    } catch (error) {
      print('get content by url failed:$error');
    }
    return url;
  }
}