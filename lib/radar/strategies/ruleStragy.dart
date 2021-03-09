import 'package:rssaid/models/radar.dart';

abstract class RuleStrategy {
  List<Radar>? detect(String url);
}