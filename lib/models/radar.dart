// @dart=2.9
class Radar {
  String title;
  String _url;
  String path;
  bool _isDocs = true;
  bool isRssHub = true;

  Radar.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    title = json['title'];
    _url = json['_url'];
    path = json['path'];
    _isDocs = json['_isDocs'];
    isRssHub = json['isRssHub'];
  }

  static List<Radar> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Radar.fromJson(value)).toList();
  }
}
