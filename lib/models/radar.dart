import 'package:equatable/equatable.dart';

class Radar extends Equatable{
  String? title;
  String? path;
  bool isRssHub = true;
  String? docs;

  Radar({required this.title, this.path, this.isRssHub = true, this.docs});

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

  @override
  List<Object?> get props => [title, path];

}
