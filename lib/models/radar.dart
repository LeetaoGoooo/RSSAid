class Radar {
  late String title;
  late String _url;
  late String path;
  late bool _isDocs = true;
  late bool isRssHub = true;

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
