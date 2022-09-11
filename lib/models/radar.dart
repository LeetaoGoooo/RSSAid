class Radar {
  String? title;
  String? _url;
  String? path;
  bool? _isDocs = true;
  bool isRssHub = true;

  Radar.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return;
    title = json['title'];
    _url = json['_url'];
    path = json['path'];
    _isDocs = json['_isDocs'];
    isRssHub = json['isRssHub'] == null ? true : json['isRssHub'];
  }

  static List<Radar> listFromJson(List<dynamic> json) {
    return json.isEmpty
        ? []
        : json.map((value) => Radar.fromJson(value)).toList();
  }
}
