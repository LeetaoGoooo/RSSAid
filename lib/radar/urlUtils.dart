import 'dart:async';
import 'dart:io';
import 'package:rssaid/common/common.dart';

class UrlUtils {
  static Future<String> getPcWebSiteUrl(String url) async {
    try {
      final httpClient = await HttpClient().autoProxy();
      httpClient.connectionTimeout = const Duration(seconds: 5);
      final request = await httpClient.getUrl(Uri.parse(url)).timeout(
        const Duration(seconds: 6),
        onTimeout: () => throw TimeoutException('Connection timed out'),
      );
      request.headers.set(
        'User-Agent',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
      );
      request.followRedirects = false;
      final response = await request.close();
      if (response.isRedirect) {
        final location = response.headers.value(HttpHeaders.locationHeader);
        if (location != null && location.isNotEmpty) return location;
      }
      return url;
    } catch (_) {
      // On any error or timeout, fall back to the original URL.
      return url;
    }
  }
}