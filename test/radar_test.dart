import 'package:rssaid/radar/radar.dart';
import "package:test/test.dart";

void main() {
  test('getContentByUrl', () async {
    var content = await RssHub.getContentByUrl(Uri.parse('https://t.me/rssaid'));
    print(content);
    expect(content, "");
  });
}
