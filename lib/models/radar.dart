class Radar {
  String title;
  String _url;
  String path;
  bool _isDocs = true;

  Radar.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    title = json['title'];
    _url = json['_url'];
    path = json['path'];
    _isDocs = json['_isDocs'];
  }

  static List<Radar> listFromJson(List<dynamic> json) {
    return json == null
        ? List<Radar>()
        : json.map((value) => Radar.fromJson(value)).toList();
  }
}
