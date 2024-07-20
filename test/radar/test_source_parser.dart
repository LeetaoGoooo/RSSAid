import 'package:rssaid/radar/source_parser.dart';
import 'package:test/test.dart';

void main() {
  group('SourceParser', () {
    test('getPosition returns correct Position for valid URL', () {
      var parser = SourceParser(
          target: "/github/branches/:user/:repo",
          url: 'https://github.com/DIYgod/RSSHub-Radar'
      );
    });
  });
}