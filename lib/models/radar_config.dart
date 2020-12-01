class RadarConfig {
  String filter;
  int limit;
  bool mode;
  String access; // 访问控制
  String tgiv;
  String scihub;
  String opencc; // s2t 简体转繁体、t2s 繁体转简体
  String format;

  RadarConfig.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    filter = json['filter'];
    limit = json['limit'];
    mode = json['mode'];
    access = json['access'];
    tgiv = json['tgiv'];
    scihub = json['scihub'];
    opencc = json['opencc'];
    format = json['format'];
  }

  static List<RadarConfig> listFromJson(List<dynamic> json) {
    return json == null
        ? List<RadarConfig>()
        : json.map((value) => RadarConfig.fromJson(value)).toList();
  }
}
