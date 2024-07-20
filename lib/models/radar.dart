class Radar {
  String? title;
  String? path;
  bool isRssHub = true;
  bool isGroup = false;
  List<String>? paths;

  Radar({required this.title, this.path, this.isRssHub = true, this.isGroup = false, this.paths});

  Radar.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return;
    title = json['title'];
    path = json['path'];
    isRssHub = json['isRssHub'] == null ? true : json['isRssHub'];
  }

  static List<Radar> listFromJson(List<dynamic> json) {
    return json.isEmpty
        ? []
        : json.map((value) => Radar.fromJson(value)).toList();
  }
}
