import 'dart:convert';

class Language {
  Language(this.value, this.name);
  String? value;
  String? name;

  Language.fromJson(Map<String, dynamic> jsonLanguage) {
    if (jsonLanguage.isEmpty) return;
    value = jsonLanguage['value'];
    name = jsonLanguage['name'];
  }

  Map<String, dynamic> toJson() => {'value': value, 'name': name};
}

class RssFormat {
  RssFormat(this.value, this.name);
  String? value;
  String? name;

  RssFormat.fromJson(Map<String, dynamic> jsonRssFormat) {
    if (jsonRssFormat.isEmpty) return;
    value = jsonRssFormat['value'];
    name = jsonRssFormat['name'];
  }

  Map<String, dynamic> toJson() => {'value': value, 'name': name};
}

class RadarConfig {
  String? filter;
  String? filterTitle;
  String? filterDescription;
  String? filterAuthor;
  String? filterTime;
  String? filterOut;
  String? filterOutTitle;
  String? filterOutDescription;
  String? filterOutAuthor;
  bool? filterCaseSensitive;
  String? limit;
  bool? mode;
  String? access; // 访问控制
  bool? scihub;
  String? opencc; // s2t 简体转繁体、t2s 繁体转简体
  RssFormat? format;

  RadarConfig();

  RadarConfig.fromJson(Map<String, dynamic> jsonRadarConfig) {
    filter = jsonRadarConfig['filter'];
    filterTitle = jsonRadarConfig['filterTitle'];
    filterDescription = jsonRadarConfig['filterDescription'];
    filterAuthor = jsonRadarConfig['filterAuthor'];
    filterTime = jsonRadarConfig['filterTime'];
    filterOut = jsonRadarConfig['filterOut'];
    filterOutTitle = jsonRadarConfig['filterOutTitle'];
    filterOutDescription = jsonRadarConfig['filterOutDescription'];
    filterOutAuthor = jsonRadarConfig['filterOutAuthor'];
    filterCaseSensitive = jsonRadarConfig['filterCaseSensitive'];
    limit = jsonRadarConfig['limit'];
    mode = jsonRadarConfig['mode'];
    access = jsonRadarConfig['access'];
    scihub = jsonRadarConfig['scihub'];
    opencc = jsonRadarConfig['opencc'];
    format = (jsonRadarConfig['format'] != null
        ? RssFormat.fromJson(json.decode(jsonRadarConfig['format']))
        : null);
  }

  static List<RadarConfig> listFromJson(List<dynamic> jsonRadarConfigList) {
    return jsonRadarConfigList
            .map((value) => RadarConfig.fromJson(value))
            .toList();
  }

  Map<String, dynamic> toJson() => {
        'filter': filter,
        'filterTitle': filterTitle,
        'filterDescription': filterDescription,
        'filterAuthor': filterAuthor,
        'filterTime': filterTime,
        'filterOut': filterOut,
        'filterOutTitle': filterOutTitle,
        'filterOutDescription': filterOutDescription,
        'filterOutAuthor': filterOutAuthor,
        'filterCaseSensitive': filterCaseSensitive,
        'limit': limit,
        'mode': mode,
        'access': access,
        'scihub': scihub,
        'opencc': opencc,
        'format': format != null ? format?.toJson() : null
      };
}
